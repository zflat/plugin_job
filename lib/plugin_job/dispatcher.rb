require "thread"
require "eventmachine"

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

  # Container class that is used to
  # expose the current host between request threads
  #
  # Access to the host parameter (via create host) 
  # should always be protected by a mutex
  #
  class HostController
    attr_reader :host
    attr_reader :host_scope
    attr_reader :plugins
    attr_reader :log
    def initialize(host_scope, plugins, log, sender, host = nil)
      @host_scope = host_scope
      @plugins = plugins
      @log = log
      @host = host
      @sender = sender
    end

    def create_host(arg, connection)
      @host = host_scope.new(arg, self, connection)
    end

    def run(command)
      @sender.run(command)
    end

    def stop
      @sender.stop
    end
  end
  
  class Dispatcher

    def initialize(host_controller, ifconfig={})
      @host_controller = host_controller
      @host_lock = Mutex.new
      @ifconfig = ifconfig
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
