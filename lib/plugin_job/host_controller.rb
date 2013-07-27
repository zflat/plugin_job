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

      @host_scope = host_scope
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
        @command = @host.pipeline_cmd
      }
    end

    def command
      cmd = nil
      @job_status_lock.synchronize {
        cmd = @command
      }
      return cmd
    end

    def job_started
      @job_status_lock.synchronize {
        @complete = false
        @command = nil
      }
    end

    def run_job(arg, connection)
      @command = arg

      begin
        # Make sure the logs inherit in the right order
        # Controller > Request > Host > Worker

        if @plugins.has_command?(command)
          cmd = String.new(command)
          @host.job = Request.new(cmd, self, connection)
          connected_log(connection).debug("Command #{cmd}")

          job_started
          @host.launch(cmd)

          # Block until job is finished
          @job_wait = Thread.new {
            while ! job_finished?
              sleep 0.05
            end
          }
          @job_wait.join
        else
          connected_log(connection).
            warn I18n.translate('plugin_job.host.unknown_command', :command => arg)
          @command = nil
        end
      rescue => detail
        connected_log(connection)
          .error I18n.translate('plugin_job.host.error', :message => detail)
        connected_log(connection)
          .debug I18n.translate('plugin_job.host.backtrace', 
                                :trace =>  detail.backtrace.join("\r\n"))
        @command = nil
      ensure
        @host.clear_job
      end
    end # run_job

    private
    def connected_log(connection)
      if @host && @host.log
        l = @host.log
      end

      if l.nil? && connection
        temp_host = host_scope.new
        temp_host.job = Request.new('', self, connection)
        l = temp_host.log
      end
      l ||= log
      return l
    end

  end # class HostController
end # module PluginJob
