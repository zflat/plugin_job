require "thread"
require "eventmachine"
require "Qt"

module PluginJob

  class DispatchHandler < EventMachine::Connection
    
    attr_reader :lock
    attr_reader :command
    
    def initialize(lock_mutex, host_controller)
      @lock = lock_mutex
      @host_controller = host_controller
    end
    
    def post_init
      @host_controller.log.info I18n.translate('plugin_job.dispatcher.connected')
    end
    
    def receive_data(requested_command)
      return if requested_command.nil?
      @command = requested_command.to_s.strip
      if lock.locked?
        notify_block
      else
        EM.defer queue_request
      end
    end # receive_data
    
    def unbind
      @host_controller.log.info I18n.translate('plugin_job.dispatcher.disconnected')
    end

    private 

    def queue_request
      proc {
        if lock.try_lock
          
          # TODO: wrap in begin rescue to make sure lock is unlocked
          if command.downcase == "exit"
            EM::stop
          else
            dispatch_job command
          end
          
          lock.unlock
        else # lock.try_lock
          notify_block
        end # lock.try_lock
      }
    end

    def dispatch_job(arg)
      if (h = @host_controller.create_host(arg,self))
        h.launch
      end
    end

    def notify_block
      @host_controller.host.block command if @host_controller.host
    end
  end # class DispatchHandler

  class Dispatcher

    def initialize(host_controller, ifconfig={})
      # Access to the host_controller (via create host) 
      # should always be protected by a mutex
      @host_controller = host_controller
      @host_lock = Mutex.new
      @ifconfig = ifconfig
    end

    def exec_app
      @app = Qt::Application.new(ARGV)
      EM::run do
        self.start
        EM.add_periodic_timer(0.01) do
          @app.process_events
        end
      end
    end
    
    def start
      # hit Control + C to stop
      Signal.trap("INT")  { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }
      
      ip = @ifconfig['host_ip']
      port = @ifconfig['port']

      unless PluginJob.configuration.nil?
        ip ||= PluginJob.configuration.host_ip
        port ||= PluginJob.configuration.port
      end

      @signature = EM::start_server(ip, port, DispatchHandler, 
                                    @host_lock, @host_controller)
      
      @host_controller.log.info I18n.translate('plugin_job.dispatcher.started', :port => port)
    end

    def stop
      EventMachine.stop_server(@signature)
    end
  end # Dispatcher
end # module PluginJob
