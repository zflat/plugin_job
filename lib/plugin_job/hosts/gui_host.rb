require "plugin_job/outputters/host_echo"
require "Qt"

module PluginJob

  class GuiHost < Qt::Object
    include LogBuilder

    signals :complete, :launch
    
    def initialize
      super
      self.connect(SIGNAL :launch) do |arg|
        @window = Qt::Widget.new()
        @window.resize(200, 120)
        @window.show()
        $qApp.process_events

        command = @request.command
        plugins = @request.plugins

        log.info command
        @job = plugins[command].new(self)
        @job.setup
        @job.run
        log.info I18n.translate('plugin_job.host.completed')
        clear_job
      end
    end # initialize

    def next_job=(request)
      clear_job
      @request = request
      @connection = request.connection
      init_log(request.log, "host")
    end

    def block(request)
      log.warn "Request #{request} blocked..."
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
