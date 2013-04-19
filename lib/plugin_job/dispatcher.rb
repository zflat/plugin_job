require "thread"
require "eventmachine"

module PluginJob

  class DispatchHandler < EventMachine::Connection

    attr_reader :lock
    attr_reader :command

    def initialize(l)
      @lock = l
    end

    def post_init
      puts "-- Dispatcher connection established"
    end

    def receive_data(requested_command)
      return if requested_command.nil?
      @command = requested_command.strip.downcase
      if lock.locked?
        notify_block
      else
        EM.defer queue_request
      end
    end # receive_data
    
    def queue_request
      proc {
        if lock.try_lock
      
          if command.to_s.strip == "exit"
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
      send_data ">>> you sent: #{arg}\n"
      sleep 5
    end

    def notify_block
      puts "Request '#{command}' blocked by an existing job."
    end

    def unbind
      puts "-- Dispatcher connection closed"
    end
    
  end
  
  class Dispatcher
    def initialize
      @lock = Mutex.new
    end
    
    def start
      return if PluginJob.configuration.nil?

      # hit Control + C to stop
      Signal.trap("INT")  { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }
      
      @signature = EM::start_server(PluginJob.configuration.host_ip, 
                                    PluginJob.configuration.port, 
                                    DispatchHandler, @lock)
        
      puts "Running Dispatcher on #{PluginJob.configuration.port}"
    end

    def stop
      EventMachine.stop_server(@signature)
    end
  end # Dispatcher
end # module PluginJob
