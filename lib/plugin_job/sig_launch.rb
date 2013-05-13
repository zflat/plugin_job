require "Qt"

module PluginJob
  class SigLaunch < Qt::Object
    signals 'run(QString)', 'stop()'
    
    def initialize
      super
      self.connect(SIGNAL("run(QString)")) do |arg|
        @window = Qt::Widget.new()
        @window.resize(200, 120)
        @window.show()
        $qApp.process_events
      end
      
      self.connect(SIGNAL("stop()")) do
        @window.close
      end
    end
  end
end # module PluginJob
