require "plugin_job/outputters/echo_outputter"

module PluginJob

  module HostEcho
    private
    
    # Override log initialization to
    # add the EchoOutputter
    def init_log(parent_log, name)
      @echo = nil if @log.nil?
      super
      if @echo.nil?
        @echo = EchoOutputter.new('echo', {:connection => @connection})
        @log.add(@echo)
      end
    end
  end # module HostEcho

end # PluginJob
