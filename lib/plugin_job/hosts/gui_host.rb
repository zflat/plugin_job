require "plugin_job/hosts/text_host"
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

      show_window

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

    def show_window
      # Show window on top
      # See https://qt-project.org/forums/viewthread/1971/#9042
      @window.showNormal
      @window.raise
      @window.activateWindow
      @window_closed = false
    end

    def block(command)
      show_window
    end

  end # class GuiHost
end # module PluginJob
