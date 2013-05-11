require "plugin_job/outputters/host_echo"

require 'Qt'

module PluginJob

  class GuiHost < TextHost
    
    include LogBuilder
    
    def initialize(command, plugins, connection, log)
      super
    end

    def launch
      # app = Qt::Application.new(ARGV)
      window = Qt::Widget.new()
      window.resize(200, 120)
      window.show()
      super
    end

  end # class GuiHost
end # module PluginJob
