require "plugin_job/outputters/host_echo"

module PluginJob

  class GuiHost < TextHost
    
    include LogBuilder
    
    def initialize(command, plugins, connection, log)
      super
    end

  end # class GuiHost
end # module PluginJob
