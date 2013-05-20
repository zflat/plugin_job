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
      if @job_status_lock.lock
        finished = @complete
        @job_status_lock.unlock
      end
      return finished
    end

    def job_finished
      if @job_status_lock.lock
        @complete = true
        @job_status_lock.unlock
      end
    end

    def job_started
      if @job_status_lock.lock
        @complete = false
        @job_status_lock.unlock
      end
    end

    def run_job(arg, connection)
      begin

        # Make sure the logs inherit in the right order
        # Controller > Request > Host > Worker
        
        @host.next_job = Request.new(arg, self, connection)

        if @plugins.has_command?(arg) || arg == ""
          @host.launch(arg)
          job_started
          
          # Block until job is finished
          @job_wait = Thread.new {
            while ! job_finished?
              sleep 0.05
            end
          }
          @job_wait.join
        else
          @host.log.warn I18n.translate('plugin_job.host.unknown_command', :command => arg)
        end
      rescue
        log.error I18n.translate('plugin_job.host.error', :message => $!)
      end
      @host.send_prompt
    end

  end # class HostController
end # module PluginJob
