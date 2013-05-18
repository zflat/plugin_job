require "plugin_job/outputters/host_echo"
require "plugin_job/hosts/widgets/select_launcher"
require "Qt"

module PluginJob

  class GuiHost < TextHost
    
    def process_request(arg)
      @window = SelectLauncher.new
      @window.resize(600, 400)
      @window.attach_log_listeners(log)

      @window.connect(SIGNAL :close){
        self.kill
        @window_closed = true
      }

      # @window.attach_kill_signal(self)

      # Show window on top
      # See https://qt-project.org/forums/viewthread/1971/#9042
      @window.showNormal
      @window.raise
      @window.activateWindow
      super
    end # process_request

    def after_run
      # Block until window is closed
      log.info I18n.translate('plugin_job.host.window_close_wait')
      while( ! @window_closed )
        Thread.sleep 0.1
      end
      super
    end

    def send_prompt
    end

  end # class GuiHost
end # module PluginJob
