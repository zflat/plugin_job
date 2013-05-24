require "Qt"

module PluginJob

  class TextHost < Qt::Object
    
    include LogBuilder

    signals :complete, :kill, "launch(QString)", :setup_complete, :run_complete

    attr_reader :plugins
    
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

    end # initialize

    def command
      @request.command
    end

    def plugins
      @request.plugins
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
      end_job
    end

    def next_job=(request)
      clear_job
      @request = request
      @connection = request.connection
      init_log(request.log, "host")
    end

    def end_job
      clear_job
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

    private

    def clear_job
      @request = nil
      @connection = nil
      @log = nil
    end

    def setup_job
    end

  end # class TextHost
end # module PluginJob
