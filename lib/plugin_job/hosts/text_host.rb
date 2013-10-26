require "Qt"

module PluginJob

  class TextHost < Qt::Object
    
    include LogBuilder

    signals :complete, :kill, "launch(QString)", :setup_complete, :run_complete

    attr_reader :plugins, :pipeline_cmd
    
    def initialize
      super

      # Hash containing execution steps
      @steps = {}

      self.connect(SIGNAL("launch(QString)")) { |arg|
        process_request(arg)
      }

      self.connect(SIGNAL :kill){
        if @request && @request.can_kill?
          @request.kill
          # end any running steps
          @steps.each do |key, val|
            Thread.kill(val)
          end
          end_job
        end
      }

      self.connect(SIGNAL :setup_complete) { after_setup }
      self.connect(SIGNAL :run_complete) { after_run }

      @pipeline_cmd = nil
      clear_job

    end # initialize

    def command
      @request.command if @request
    end

    def plugins
      @request.plugins if @request
    end

    def valid_job?
      @request.passed_validation? if @request
    end
    
    def process_request(arg)
      if arg != ""
        # Run the setup step asynchronisly
        @steps[:setup] = Thread.new {
          @request.setup
        }
      end
    end

    def after_setup
      log.info @request.computer_context_info

      # Execute the Run step asynchronisly
      @steps[:run] = Thread.new {@request.run}
    end

    def after_run
      @pipeline_cmd = nil
      @pipeline_cmd = String.new(@request.pipeline_cmd) if @request.pipeline_cmd
      end_job
    end

    def job=(request)
      @request = request
      @connection = request.connection
      init_log(request.log, "host")
    end

    def end_job
      emit complete
    end

    def block(command, connection=nil)
      if log
        log.warn I18n.translate('plugin_job.host.block', :command => command)
      end
      send_prompt(connection)
    end

    def send_prompt(connection=nil)
    end

    def job_cleared?
      @request.nil?
    end

    def cleanup_job
      if @request && @request.can_cleanup?
        @request.cleanup
        # TODO: make sure all log messages are sent before clearing
        # the job objects
        clear_job
      end
    end

    private

    def clear_job
      @connection = nil
      @log = nil
      @request.end_cleanup unless @request.nil?
      @request = nil
    end

    def setup_job
    end

  end # class TextHost
end # module PluginJob
