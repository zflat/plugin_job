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
        # end any running steps
        @steps.each do |key, val|
          Thread.kill(val)
        end
        end_job
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
      @request.passed_validation?
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
      @pipeline_cmd = @request.pipeline_cmd
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

    def block(command)
      log.warn I18n.translate('plugin_job.host.block', :command => command)
      send_prompt
    end

    def send_prompt(connection=nil)
    end

    def job_cleared?
      @request.nil?
    end

    def clear_job
      @request = nil
      @connection = nil
      @log = nil
    end

    private


    def setup_job
    end

  end # class TextHost
end # module PluginJob
