require "plugin_job/hosts/text_host"
require "plugin_job/hosts/widgets/select_launcher"
require "Qt"

module PluginJob

  class GuiHost < TextHost
    
    def process_request(command)
      if @window.nil?
        @window = SelectLauncher.new
        @window.resize(600, 400)
        @window.attach_log_listeners(log)

        @window.populate_command_options(plugins.command_list)

        @window.connect(SIGNAL :close){
          self.kill
          @window_closed = true
        }

        @window.select_form.connect(SIGNAL("command_selected(QString)")){ |arg|
          @request.command = arg
          process_request(arg)
        }

        show_window

        if command != ""
          # Show current selection
          @window.select_form.select(command)
        end
      elsif command != ""      
        super
      end
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

    def clear_job
      super
      @window = nil
    end

  end # class GuiHost
end # module PluginJob
