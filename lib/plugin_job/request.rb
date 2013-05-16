require "plugin_job/outputters/host_echo"
require "Qt"

module PluginJob

  class Request
    attr_reader :command, :connection, :plugins
    attr_accessor :after_setup, :after_run
    
    include LogBuilder

    def initialize(command, controller, connection)
      @command = command
      @controller = controller
      @connection = connection
      @plugins = controller.plugins
      init_log(controller.log, "request")
    end # initialize

    def setup
      @job = plugins[@command].new(self)
      @job.setup
      # Signal setup complete
      after_setup.call      
    end

    def run
      @job.run
      # Signal run complete
      after_run.call
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