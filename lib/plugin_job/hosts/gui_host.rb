require "plugin_job/outputters/host_echo"
require "plugin_job/hosts/widgets/select_launcher"
require "Qt"

module PluginJob

  class GuiHost < Qt::Object
    include LogBuilder

    signals :complete, :launch
    
    def initialize
      super
      self.connect(SIGNAL :launch) { |arg|
        command = @request.command
        plugins = @request.plugins

        @window = SelectLauncher.new
        @window.resize(200, 120)
        @window.show()
        
        log.info command
        
        # Run the setup step asynchronisly
        @setup_step = Thread.new {@request.setup}

      }
    end # initialize

    def after_setup
      proc {
        # Execute the Run step asynchronisly
        @run_step = Thread.new { @request.run }
      }
    end

    def after_run
      proc {
        log.info I18n.translate('plugin_job.host.completed')
        send_prompt
        clear_job
      }
    end

    def next_job=(request)
      clear_job
      @request = request
      @connection = request.connection
      init_log(request.log, "host")
      
      # Job step callbacks
      @request.after_setup = after_setup
      @request.after_run = after_run
    end

    def block(request)
      log.warn "Request #{request} blocked..."
      send_prompt
    end

    def send_prompt
    end

    private

    def clear_job
      @request = nil
      @connection = nil
      @log = nil
    end

    def setup_job
    end

  end # class GuiHost
end # module PluginJob
