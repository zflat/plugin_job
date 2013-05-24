require "plugin_job/hosts/widgets/log_text"
require "plugin_job/hosts/widgets/about_dialog"
require "plugin_job/hosts/widgets/job_selection_form"
require "plugin_job/outputters/emitter_outputter"
require "Qt"

module PluginJob

  class SelectLauncher < Qt::MainWindow

    signals :close_sig, "command_selected(QString)", :notify_errors, :notify_warnings, :notify_success

    attr_reader :select_form
    
    def initialize
      super
      self.setWindowTitle(I18n.translate('plugin_job.launcher.title'))

      # See http://usefulfor.com/ruby/2007/07/31/ruby-qt-menu-bar-status-bar-and-resources/
      @menubar = Qt::MenuBar.new(self)
      @menubar.setObjectName('menubar')
      # Top level menu items
      @menuFile = Qt::Menu.new(@menubar)
      @menuFile.setObjectName('menufile')
      @menuFile.setTitle(I18n.translate('plugin_job.widget.select_launcher.menu.file'))
      
      @menuHelp = Qt::Menu.new(@menubar)
      @menuHelp.setObjectName('menuHelp')
      @menuHelp.setTitle(I18n.translate('plugin_job.widget.select_launcher.menu.help'))
      
      # add the top level menu items to the menu bar
      @menubar.addAction(@menuFile.menuAction())
      @menubar.addAction(@menuHelp.menuAction())

      self.setMenuBar(@menubar)

      # create menu actions
      @actionSaveLog = Qt::Action.new(self)
      @actionSaveLog.setObjectName('actionSaveLog')
      tr_key = 'plugin_job.widget.select_launcher.menu.save_log'
      @actionSaveLog.setText(I18n.translate(tr_key))
      @actionSaveLog.connect(SIGNAL :triggered){
        @log_page.save_to_file(self,
                               I18n.translate(tr_key), 
                               File.join(Dir.home,
                                         "#{Time.now.strftime('%Y%m%d%H%M%S')}_log.txt"),
                               "Log files (*.txt, *.log)")
      }
      @menuFile.addAction(@actionSaveLog)

      @actionSaveErr = Qt::Action.new(self)
      @actionSaveErr.setObjectName('actionSaveErr')
      tr_key = 'plugin_job.widget.select_launcher.menu.save_errors'
      @actionSaveErr.setText(I18n.translate(tr_key))
      @actionSaveErr.connect(SIGNAL :triggered){
        @error_page.save_to_file(self,
                                 I18n.translate(tr_key), 
                                 File.join(Dir.home, 
                                           "#{Time.now.strftime('%Y%m%d%H%M%S')}_errors_warnings_log.txt"),
                                 "Log files (*.txt, *.log)")
      }
      @menuFile.addAction(@actionSaveErr)
      @menuFile.addSeparator()

      @actionExit = Qt::Action.new(self)
      @actionExit.setObjectName('actionExit')
      @actionExit.setText('Exit')
      @actionExit.connect(SIGNAL :triggered){
        self.close
      }
      @menuFile.addAction(@actionExit)

      @actionAbout = Qt::Action.new(self)
      @actionAbout.setObjectName('actionAbout')
      @actionAbout.setText(I18n.translate('plugin_job.widget.select_launcher.menu.about'))
      @actionAbout.connect(SIGNAL :triggered){
        dialog = AboutDialog.new(self)
        dialog.exec
      }
      @menuHelp.addAction(@actionAbout)
      
      
      # create and attach the status bar
      @statusbar = Qt::StatusBar.new(self)
      @statusbar.setObjectName('statusbar')
      self.setStatusBar(@statusbar)
      
      @progressbar = Qt::ProgressBar.new
      @progressbar.setMinimum(0)
      @progressbar.setMaximum(100)
      # @statusbar.addWidget(@progressbar)

      # create the central widget
      @central = Qt::Widget.new
      @central_layout = Qt::VBoxLayout.new

      # job selection form
      @select_form = JobSelectionForm.new

      # placeholder for job UI
      @job_ui = Qt::Widget.new
      @job_ui_layout = Qt::VBoxLayout.new
      # @job_ui_layout.addWidget(w)
      @job_ui.setLayout(@job_ui_layout)

      # create the tabs
      @tabs = Qt::TabWidget.new
      @log_page = LogText.new

      @tabs.addTab(@log_page, I18n.translate('plugin_job.widget.select_launcher.tab.log'))
      @log_page.showMaximized()

      @error_page = LogText.new
      @tabs.addTab(@error_page, I18n.translate('plugin_job.widget.select_launcher.tab.error'))
      
      # Add components to the layout
      @central_layout.addWidget(@select_form)
      @central_layout.addWidget(@job_ui)
      @central_layout.addWidget(@tabs)

      @central.setLayout(@central_layout)
      self.setCentralWidget(@central)

      self.connect(SIGNAL :notify_errors) do
        show_errors
      end

      self.connect(SIGNAL :notify_warnings) do
        show_warnings
      end

      self.connect(SIGNAL :notify_success) do
        show_success
      end
    end

    def populate_command_options(commands)
      @select_form.populate_command_options(commands)
    end

    def attach_log_listeners(log, header)
      @log_header_text = header
      @log_all = EmitterOutputter.new("Worker")
      @log_all.emitter.connect(SIGNAL("log(QString)")) do |data|
        @log_page.text_area.appendPlainText(data[0..-2])
      end
      
      @log_error = EmitterOutputter.new("Worker")
      @log_error.only_at WARN, ERROR, FATAL
      @log_error.emitter.connect(SIGNAL("log(QString)")) do |data|
        if @error_page.text_area.plainText.length < 1
          @error_page.text_area.appendPlainText(@log_header_text)
        end

        @error_page.text_area.appendPlainText(data)
      end

      log.add(@log_all)
      log.add(@log_error)
    end

    def attach_widget(w)
      @job_ui_layout.addWidget(w)
    end

    def closeEvent(event)
      emit close_sig
      super
    end # closeEvent

    def show_errors
      @statusbar.setStyleSheet("QStatusBar {background: red}")
    end

    def show_warnings
      @statusbar.setStyleSheet("QStatusBar {background: yellow}")
    end

    def show_success
      @statusbar.setStyleSheet("QStatusBar {background: green}")      
    end
    
  end # class SelectLauncher < Qt::MainWindow

end # module PluginJob
