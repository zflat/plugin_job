require "plugin_job/hosts/widgets/log_text"
require "plugin_job/hosts/widgets/job_selection_form"
require "plugin_job/outputters/qt_plain_text_outputter"
require "Qt"

module PluginJob

  class SelectLauncher < Qt::MainWindow

    signals :close, "command_selected(QString)"

    attr_reader :select_form
    
    def initialize
      super
      self.setWindowTitle(I18n.translate('plugin_job.launcher.title'))

      # create and attach the status bar
      @statusbar = Qt::StatusBar.new(self)
      @statusbar.setObjectName('statusbar')
      self.setStatusBar(@statusbar)

      # create the central widget
      @central = Qt::Widget.new
      @central_layout = Qt::VBoxLayout.new

      # job selection form
      @select_form = JobSelectionForm.new

      # placeholder for job UI
      
      

      # create the tabs
      @tabs = Qt::TabWidget.new
      @log_page = LogText.new

      @tabs.addTab(@log_page, I18n.translate('plugin_job.widget.select_launcher.tab.log'))
      @log_page.showMaximized()

      @error_page = LogText.new
      @tabs.addTab(@error_page, I18n.translate('plugin_job.widget.select_launcher.tab.error'))
      
      # Add components to the layout
      @central_layout.addWidget(@select_form)
      @central_layout.addWidget(@tabs)

      @central.setLayout(@central_layout)
      self.setCentralWidget(@central)
    end

    def populate_command_options(commands)
      @select_form.populate_command_options(commands)
    end

    def attach_log_listeners(log)
      @log_all = QtPlainTextOutputter.new("Worker", :widget => @log_page.text_area)
      @log_error = QtPlainTextOutputter.new("Worker", :widget => @error_page.text_area)
      @log_error.only_at WARN, ERROR, FATAL

      log.add(@log_all)
      log.add(@log_error)
    end

    def attach_kill_signal(parent)
      @kill_reciever = parent
    end
    
    def closeEvent(event)
      emit close
      super
    end # closeEvent
    
  end # class SelectLauncher < Qt::MainWindow

end # module PluginJob
