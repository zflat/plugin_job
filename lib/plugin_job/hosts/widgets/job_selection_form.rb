require "Qt"

module PluginJob

  class JobSelectionForm < Qt::Widget

    signals "command_selected(QString)", "select(QString)"
    
    def initialize(parent=nil)
      super(parent)

      @label = Qt::Label.new("#{I18n.translate('plugin_job.launcher.select_label')}:", self)
      @label.setSizePolicy(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)

      @box = Qt::ComboBox.new(self)
      @btn = Qt::PushButton.new(I18n.translate('plugin_job.launcher.select_btn'), self)
      @btn.setSizePolicy(Qt::SizePolicy::Fixed, Qt::SizePolicy::Fixed)

      @btn.connect(SIGNAL :clicked) {
        # select_job(
        emit select(@box.currentText)
      }

      self.connect(SIGNAL("select(QString)")){ |arg| select_job(arg)}

      @layout = Qt::HBoxLayout.new
      @layout.addWidget(@label)
      @layout.addWidget(@box)
      @layout.addWidget(@btn)
      self.setLayout(@layout)
    end

    def select_job(command)
      emit command_selected(command)
      @box.setCurrentIndex(@index_map[command.to_s])
      @box.setEnabled(false)
      @btn.setEnabled(false)
    end

    def populate_command_options(commands)
      @index_map = {}
      i=0
      commands.each do |c|
        if c != ''
          @index_map[c.to_s] = i
          i += 1
          @box.addItem(c.to_s)
        end
      end
    end

    def indicate_warning
      @box.setStyleSheet("QComboBox {border: 2px solid yellow}")
    end

    def indicate_error
      @box.setStyleSheet("QComboBox {border: 2px solid red}")
    end

  end #   class JobSelectionForm < Qt::Widget

end # module PluginJob
