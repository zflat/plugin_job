require "plugin_job/hosts/widgets/log_text"
require "plugin_job/outputters/qt_plain_text_outputter"
require "Qt"

module PluginJob

  class SelectLauncher < Qt::MainWindow
    
    def initialize
      super
      self.setWindowTitle(I18n.translate('plugin_job.launcher.title'))

      # create and attach the status bar
      @statusbar = Qt::StatusBar.new(self)
      @statusbar.setObjectName('statusbar')
      self.setStatusBar(@statusbar)

      @tabs = Qt::TabWidget.new
      @log_page = LogText.new
      @tabs.addTab(@log_page, "Log")
      @log_page.showMaximized()

      @error_page = LogText.new
      @tabs.addTab(@error_page, "Errors & Warnings")
      
      self.setCentralWidget(@tabs)
    end

    def attach_log_listeners(log)
      @log_all = QtPlainTextOutputter.new("Worker", :widget => @log_page.text_area)
      @log_error = QtPlainTextOutputter.new("Worker", :widget => @error_page.text_area)
      @log_error.only_at WARN, ERROR, FATAL

      log.add(@log_all)
      log.add(@log_error)
    end
    
    def closeEvent(event)
      puts "Close event sent"
      super
    end
    
  end

end
