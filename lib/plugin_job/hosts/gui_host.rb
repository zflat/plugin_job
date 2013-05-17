require "plugin_job/outputters/host_echo"
require "plugin_job/hosts/widgets/select_launcher"
require "Qt"

module PluginJob

  class GuiHost < TextHost
    
    def process_request(arg)
      @window = SelectLauncher.new
      @window.resize(600, 400)
      @window.attach_log_listeners(log)
      @window.show()

      super
    end # process_request

    def send_prompt
    end

  end # class GuiHost
end # module PluginJob
