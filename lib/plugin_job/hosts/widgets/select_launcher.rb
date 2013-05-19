require "plugin_job/hosts/widgets/log_text"
require "plugin_job/outputters/qt_plain_text_outputter"
require "Qt"

module PluginJob

  class SelectLauncher < Qt::MainWindow

    signals :close, "command_selected(QString)"
    
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

      # create the job selection form
      @select_form = Qt::Widget.new
      @select_label = Qt::Label.new("Job:", @select_form)
      @select_box = Qt::ComboBox.new(@select_form)
      @select_btn = Qt::PushButton.new("Run", @select_form)

      @select_btn.connect(SIGNAL :clicked) {
        puts "clicked"
        emit command_selected(@select_box.currentText)
        @select_box.setEnabled(false)
        @select_btn.setEnabled(false)
      }
      
      @select_layout = Qt::HBoxLayout.new
      @select_layout.addWidget(@select_label)
      @select_layout.addWidget(@select_box)
      @select_layout.addWidget(@select_btn)
      @select_form.setLayout(@select_layout)
      
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
      commands.each do |c|
        @select_box.addItem(c.to_s)
      end
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
    end
    
  end

end
