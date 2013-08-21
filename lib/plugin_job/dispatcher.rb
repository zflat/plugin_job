require "thread"
require "eventmachine"

module PluginJob

  class DispatchHandler < EventMachine::Connection
    
    attr_reader :block, :host_sem
    attr_reader :command
    
    def initialize(host_controller, job_mutex, host_mutex)
      # Use the mutext to ensure let a running job block
      @block = job_mutex
      
      # Use a mutex to make sure only one request is sent to the host at a time
      @host_sem = host_mutex

      @host_controller = host_controller
    end
    
    def post_init
      host_sem.synchronize {
        @host_controller.log.info I18n.translate('plugin_job.dispatcher.connected')
      }
    end
    
    def receive_data(requested_command)
      return if requested_command.nil?
      @command = requested_command.to_s.strip

      EM.defer queue_request
    end # receive_data
    
    def unbind
      host_sem.synchronize {
        @host_controller.log.info I18n.translate('plugin_job.dispatcher.disconnected')
      }
    end

    private 

    def queue_request
      proc {
        if block.try_lock
          while(command)
            begin
              if command.downcase == "exit"
                EM::stop
              else
                dispatch_job command
              end
              sleep 0.05
              @command = @host_controller.command && String.new(@host_controller.command)
            rescue => detail
              @host_controller.log
                .error I18n.translate('plugin_job.host.error', :message => detail)
              @host_controller.log
                .debug I18n.translate('plugin_job.host.backtrace', 
                                      :trace =>  detail.backtrace.join("\r\n")) 
              break
            end # begin/rescue
          end # while command.present?
          
          block.unlock
          sleep 0.05
          @host_controller.host.send_prompt(self)
        else # block.try_lock
          notify_block
        end
      }
    end

    def dispatch_job(arg)
      @host_controller.run_job(arg, self)
    end

    def notify_block
      host_sem.synchronize {
        @host_controller.host.block command if @host_controller.host
      }
    end
  end # class DispatchHandler

  class Dispatcher

    def initialize(host_controller, ifconfig={})
      # Access to the host_controller (via create host) 
      # should always be protected by a mutex
      @host_controller = host_controller
      @job_lock = Mutex.new
      @host_lock = Mutex.new
      @ifconfig = ifconfig
    end

    def exec_app
      @app = Qt::Application.new(ARGV)
      EM::run do
        self.start
        EM.add_periodic_timer(0.05) do
          begin
            @app.process_events
          rescue => detail
            @host_controller.log
              .fatal I18n.translate('plugin_job.host.error', :message => $!)
            @host_controller.log.
              debug I18n.translate('plugin_job.host.backtrace', 
                                  :trace =>  detail.backtrace.join("\r\n"))
          end
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
                                    @host_controller, @job_lock, @host_lock)
      
      @host_lock.synchronize {
        @host_controller.log.info I18n.translate('plugin_job.dispatcher.started', :port => port)
      }
    end

    def stop
      EventMachine.stop_server(@signature)
    end
  end # Dispatcher
end # module PluginJob
