require "plugin_job/outputters/host_echo"

require 'Qt'

module PluginJob

  class GuiHost < TextHost
    
    include LogBuilder
    
    def initialize(command, host, connection)
      super
    end

    def launch
      @host.run @command
      super
      @host.stop
    end

  end # class GuiHost
end # module PluginJob
