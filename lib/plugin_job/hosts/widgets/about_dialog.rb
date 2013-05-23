require "Qt"

module PluginJob

  class AboutDialog < Qt::Dialog
    
    def initialize(parent=nil, flags = 0)
      super
      @lib_name = 
        Qt::Label.new(I18n.translate('plugin_job.widget.about.lib_name'))
      @lib_version = 
        Qt::Label.new(I18n.translate('plugin_job.widget.about.lib_version', 
                                     :version => PluginJob::VERSION)) 
      @ruby_version =
        Qt::Label.new(I18n.translate('plugin_job.widget.about.ruby_version', 
                                     :version => RUBY_VERSION,
                                     :patch => RUBY_PATCHLEVEL,
                                     :platform => RUBY_PLATFORM)) 
      
      @layout = Qt::VBoxLayout.new()
      @layout.addWidget(@lib_name)
      @layout.addWidget(@lib_version)
      @layout.addWidget(@ruby_version)
      self.setLayout(@layout)
    end

  end

end
