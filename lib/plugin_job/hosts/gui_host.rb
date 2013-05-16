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
        $qApp.process_events
        
        log.info command
        @job = plugins[command].new(self)

        # Call the setup step asynchronisly
        setup_step = Thread.new {@job.setup}
        setup_step.join

        # Call the run step asynchronisly
        run_step = Thread.new do 
          @job.run 
          log.info I18n.translate('plugin_job.host.completed')          
        end
        run_step.join

        send_prompt
        clear_job
      }
    end # initialize

    def next_job=(request)
      clear_job
      @request = request
      @connection = request.connection
      init_log(request.log, "host")
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
