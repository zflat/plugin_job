require 'Qt4'

module PluginJob
  # Controller class that is used to
  # expose the current host and to initiate
  # running and stopping of jobs
  #
  class HostController
    attr_reader :host
    attr_reader :host_scope
    attr_reader :plugins
    attr_reader :log

    def initialize(host_scope, plugins, log, host = nil)
      @host_scope = host_scope
      @plugins = plugins
      @log = log
      @host = host
      @sender = SigLaunch.new
    end

    def create_host(arg, connection)
      @host = host_scope.new(arg, self, connection)
    end

    def run(command)
      @sender.run(command)
    end

    def stop
      @sender.stop
    end
  end # class HostController
end # module PluginJob
