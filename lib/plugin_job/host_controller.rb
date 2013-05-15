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
      @plugins = plugins
      @log = log
      @host = host_scope.new
    end

    def run_job(arg, connection)
      # TODO: Connect the host signal :complete to the job
      @host.next_job = Request.new(arg, self, connection)
      if @plugins.has_command?(arg)
        @host.launch          
      else
        @host.log.warn I18n.translate('plugin_job.host.unknown_command')
      end
    end

  end # class HostController
end # module PluginJob
