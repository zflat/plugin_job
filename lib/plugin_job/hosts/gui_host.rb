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
        @window.attach_log_listeners(log, @request.computer_context_info)
        @window.populate_command_options(plugins.command_list)

        # watch for errors and warnings
        @err_watch = FlagOutputter.new("errors warnings fatal")
        @err_watch.only_at ERROR, FATAL
        log.add(@err_watch)
        @err_watch.emitter.connect(SIGNAL :flag){
          notify_errors(:indicate_only => true)
        }          

        @warn_watch = FlagOutputter.new("errors warnings fatal")
        @warn_watch.only_at WARN
        log.add(@warn_watch)
        @warn_watch.emitter.connect(SIGNAL :flag){
          unless @err_watch.flag
            @window.indicate_warnings if @window
          end
        }

        @window.connect(SIGNAL :close_sig){
          if @request && @request.can_kill?
            self.kill
            @window_closed = true
          end
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
        @window.setWindowTitle("#{command} |  #{I18n.translate('plugin_job.launcher.title')}")
        super
      end
    end # process_request

    def after_setup
      if @request && @request.job
        # hide window if necessary
        if @request.job.meta[:silent]
          @window.showMinimized
        end
        
        # add job widget to GUI if necessary
        if @request.job.respond_to?(:widget)
          @window.attach_widget(@request.job.widget)
        end
      end

      super
    end

    def after_run
      end_silent = @request && @request.job.meta[:silent] && !@err_watch.flag

      if @err_watch.flag
        notify_errors
      elsif @warn_watch.flag
        @window.notify_warnings if @window
      else
        @window.notify_success if @window
      end
      
      if end_silent
        # close the window
        @window.close if @window
        super
      else
        # Block in the background until window is closed
        @window_close_wait = true
        Thread.new{
          while( ! @window_closed )
            sleep 0.1
          end
          @window_close_wait = false
          super
        }
      end # if end_silent
    end # after_run

    def show_window
      # Show window on top
      # See https://qt-project.org/forums/viewthread/1971/#9042
      unless @window.nil?
        @window.showNormal
        @window.raise
        @window.activateWindow
        @window_closed = false
      end
    end

    def notify_errors(opts={})
      show_window
      if @window
        if opts[:indicate_only]
          @window.indicate_errors
        else
          @window.notify_errors
        end
      end
    end

    def block(command, connection=nil)
      if @window_close_wait
        log.info I18n.translate('plugin_job.host.window_close_wait')
      end
      show_window
    end

    def clear_job
      super
      # Ensure the window is closed and disposed
      if @window
        @window.close
      end
      @window = nil
    end

  end # class GuiHost
end # module PluginJob
