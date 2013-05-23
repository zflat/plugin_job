require 'Qt'

module PluginJob
  # Controller class that is used to
  # expose the current host and to initiate
  # running and finishing of jobs
  #
  class HostController
    attr_reader :host
    attr_reader :host_scope
    attr_reader :plugins
    attr_reader :log

    def initialize(host_scope, plugins, log, host = nil)
      @plugins = plugins
      @log = log
      @job_status_lock = Mutex.new

      @host = host_scope.new
      @host.connect(SIGNAL :complete){ job_finished }
    end

    def job_finished?
      finished = nil
      @job_status_lock.synchronize {
        finished = @complete
      }
      return finished
    end

    def job_finished
      @job_status_lock.synchronize {
        @complete = true
      }
    end

    def job_started
      @job_status_lock.synchronize {
        @complete = false
      }
    end

    def run_job(arg, connection)
      begin

        # Make sure the logs inherit in the right order
        # Controller > Request > Host > Worker
        
        if @plugins.has_command?(arg) || arg == ""
          @host.next_job = Request.new(arg, self, connection)
          
          job_started
          @host.launch(arg)
          
          # Block until job is finished
          @job_wait = Thread.new {
            while ! job_finished?
              sleep 0.05
            end
          }
          @job_wait.join
        else
          connected_log.warn I18n.translate('plugin_job.host.unknown_command', :command => arg)
        end
      rescue
        connected_log.error I18n.translate('plugin_job.host.error', :message => $!)
      end
      @host.send_prompt
    end

    def connected_log
      (@host.log.nil?) ? log : @host.log
    end

  end # class HostController
end # module PluginJob
