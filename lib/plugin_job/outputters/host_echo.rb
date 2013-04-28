require "plugin_job/outputters/echo_outputter"

module PluginJob

  module HostEcho
    private
    def init_log(parent_log)
      super

      if @echo.nil?
        @echo = EchoOutputter.new('echo', {:connection => @connection})
        @log.add(@echo)
      end
    end
  end # module HostEcho

end # PluginJob
