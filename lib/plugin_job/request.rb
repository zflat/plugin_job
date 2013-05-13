require "plugin_job/outputters/host_echo"

module PluginJob

  class Request
    attr_reader :command, :connection, :plugins
    
    include LogBuilder

    def initialize(command, controller, connection)
      @command = command
      @controller = controller
      @connection = connection
      @plugins = controller.plugins
      init_log(controller.log, "request")
    end # initialize

    def valid?
      @plugins.has_command?(@command)
    end
    
    private
    def launch
      begin
        if @plugins.has_command?(@command)
          @controller.run @command
        else
log.info I18n.translate('plugin_job.host.unknown_command')
        end
      rescue
        log.error I18n.translate('plugin_job.host.error', :message => $!)
      end
    end

  end # class Request

end # module PluginJob
