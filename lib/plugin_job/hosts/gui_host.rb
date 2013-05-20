require "plugin_job/hosts/text_host"
require "plugin_job/hosts/widgets/select_launcher"
require "plugin_job/outputters/flag_outputter"
require "Qt"

module PluginJob

  class GuiHost < TextHost
    
    def process_request(command)
      if @window.nil?
        @window = SelectLauncher.new
        @window.resize(600, 400)
        @window.attach_log_listeners(log)

        # watch for errors and warnings
        @err_watch = FlagOutputter.new("errors warnings fatal")
        @err_watch.only_at ERROR, FATAL
        log.add(@err_watch)
        @warn_watch = FlagOutputter.new("errors warnings fatal")
        @warn_watch.only_at WARN
        log.add(@warn_watch)
        
        @window.populate_command_options(plugins.command_list)

        @window.connect(SIGNAL :close_sig){
          self.kill
          @window_closed = true
        }

        @window.select_form.connect(SIGNAL("command_selected(QString)")){ |arg|
          @request.command = arg
          process_request(arg)
        }

        if command != ""
          # Show current selection
          @window.select_form.select(command)
        end

        show_window

      elsif command != ""      
        super
      end
    end # process_request

    def after_setup
      # hide window if necessary
      if @request.job.silent?
        @window.showMinimized
      end

      # add widget to GUI if necessary
      if @request.job.respond_to?(:widget)
        # @request.job.widget
      end

      super
    end

    def after_run

      end_silent = @request.job.silent? && !@err_watch.flag

      if @err_watch.flag
        notify_errors
      elsif @warn_watch.flag
        @window.notify_warnings
      else
        @window.notify_success
      end
      
      if end_silent
        # close the window
        @window.close
        super
      else
        # Block until window is closed
        log.info I18n.translate('plugin_job.host.window_close_wait')
        while( ! @window_closed )
          Thread.sleep 0.1
        end
        super
      end # if end_silent

    end # after_run

    def show_window
      # Show window on top
      # See https://qt-project.org/forums/viewthread/1971/#9042
      @window.showNormal
      @window.raise
      @window.activateWindow
      @window_closed = false
    end

    def notify_errors
      show_window
      @window.notify_errors
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
