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
      @host.connect(SIGNAL :complete){ job_finish_isr }
    end

    def job_finished?
      finished = nil
      @job_status_lock.synchronize {
        finished = @complete
      }
      return finished
    end

    # Interrupt service routine to handle
    # the job finished signal
    def job_finish_isr
      @job_status_lock.synchronize {
        @command = nil
        @command = @host.pipeline_cmd
        @complete = true
      }
    end

    def command
      cmd = nil
      @job_status_lock.synchronize {
        cmd = @command
      }
      return cmd
    end

    def command=(arg)
      @job_status_lock.synchronize {
        @command = arg
      }
    end

    def job_started
      @job_status_lock.synchronize {
        @complete = false
        @canceled = false
        @command = nil
      }
    end

    def run_job(arg, connection)
      command = arg

      begin
        # Make sure the logs inherit in the right order
        # Controller > Request > Host > Worker

        if @plugins && @plugins.recognize_command?(command)
          cmd = String.new(command)
          command=nil
          @host.job = Request.new(cmd, self, connection)
          connected_log(connection).debug("Command #{cmd}")

          job_started
          @host.launch(cmd)

          # Block until job is finished or canceled
          @job_wait = Thread.new {
            while ! (job_finished?)
              sleep 0.05
            end
          }
          @job_wait.join

          # Next job in the pipeline
          command = @host.pipeline_cmd 
          if !command.nil?
            run_job(command, arg)
          end
        else # not recognized?
          connected_log(connection).
            warn I18n.translate('plugin_job.host.unknown_command', :command => arg)
          command = nil
        end
      rescue => detail
        connected_log(connection)
          .error I18n.translate('plugin_job.host.error', :message => detail)
        connected_log(connection)
          .debug I18n.translate('plugin_job.host.backtrace', 
                                :trace =>  detail.backtrace.join("\r\n"))
        command = nil
      end
    end # run_job

    def cleanup_job(connection)
      @host.send_prompt(connection)
      @host.cleanup_job
    end

    def notify_block(command, connection)
      begin
        @host.block(command, connection) if @host
      rescue => detail
        connected_log(connection)
          .error I18n.translate('plugin_job.host.error', :message => detail)
        connected_log(connection)
          .debug I18n.translate('plugin_job.host.backtrace', 
                                :trace =>  detail.backtrace.join("\r\n")) 
      end # begin/rescue
    end # notify_block

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
    end # connected_log

  end # class HostController
end # module PluginJob
