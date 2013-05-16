require "Qt"

module PluginJob

  class SelectLauncher < Qt::Widget
    
    def closeEvent(event)
      puts "Close event sent"
      super
    end
    
  end

end
