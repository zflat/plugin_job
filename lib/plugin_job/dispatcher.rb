require "thread"
require "eventmachine"

module PluginJob

  class DispatchHandler < EventMachine::Connection
    
    attr_reader :lock
    attr_reader :command
    
    def initialize(lock_mutex, host_type, current_dispatcher_launch)
      @lock = lock_mutex
      @host_scope = host_type
      @dispatcher_launch = current_dispatcher_launch
    end
    
    def post_init
      @dispatcher_launch.log.info I18n.translate('plugin_job.dispatcher.connected')
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
      @dispatcher_launch.log.info I18n.translate('plugin_job.dispatcher.disconnected')
    end

    private 

    def queue_request
      proc {
        if lock.try_lock
      
          if command.downcase == "exit"
            EM::stop
          end
          
          dispatch_job command
          
          lock.unlock
        else # lock.try_lock
          notify_block
        end # lock.try_lock
      }
    end

    def dispatch_job(arg)
      if (h = @host_scope.new(arg, @dispatcher_launch.plugins, 
                              self, @dispatcher_launch.log))
        @dispatcher_launch.host = h
        h.launch
      end
    end

    def notify_block
      @dispatcher_launch.host.block command if @dispatcher_launch.host
    end
  end # class DispatchHandler

  # Container class that is used to
  # expose the current host between request threads
  #
  # Access to the host parameter should always be protected
  # by a mutex
  class LaunchHost
    attr_accessor :host
    attr_reader :plugins
    attr_reader :log
    def initialize(plugins, log, host = nil)
      @plugins = plugins
      @log = log
      @host = host
    end
  end
  
  class Dispatcher

    def initialize(host_type, plugins_collection, ifconfig={}, log=nil)
      @host_type = host_type
      @host_lock = Mutex.new
      @current_host = LaunchHost.new plugins_collection, log
      @ifconfig = ifconfig
    end
    
    def start
      return if PluginJob.configuration.nil?

      # hit Control + C to stop
      Signal.trap("INT")  { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }
      
      ip = @ifconfig['host_ip'] || PluginJob.configuration.host_ip
      port = @ifconfig['port'] || PluginJob.configuration.port
      @signature = EM::start_server(ip, port, DispatchHandler, 
                                    @host_lock, @host_type, @current_host)
      
      @current_host.log.info I18n.translate('plugin_job.dispatcher.started', :port => port)
    end

    def stop
      EventMachine.stop_server(@signature)
    end
  end # Dispatcher
end # module PluginJob
