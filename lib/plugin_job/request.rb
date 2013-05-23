require "plugin_job/outputters/host_echo"
require "Qt"
require "socket"

module PluginJob

  class Request

    attr_reader :connection, :plugins, :job

    attr_accessor :command
    
    include LogBuilder

    def initialize(command, controller, connection)
      @command = command
      @controller = controller
      @connection = connection
      @plugins = controller.plugins
      init_log(controller.log, "request")
    end # initialize

    def setup
      begin
        @job = plugins[@command].new(@controller.host)
        @job.setup
      rescue
        connected_log.error I18n.translate('plugin_job.host.error', :message => $!)
      ensure
        # Signal setup complete unless the job was killed
        unless @controller.host.job_cleared?
          @controller.host.setup_complete
        end
      end
    end

    def run
      begin
        @job.run
        connected_log.info I18n.translate('plugin_job.host.completed')
      rescue
        connected_log.error I18n.translate('plugin_job.host.error', :message => $!)
      ensure
        # Signal run complete unless the job was killed
        unless @controller.host.job_cleared?        
          @controller.host.run_complete
        end
      end
    end

    def connected_log
      (@job.nil? || @job.log.nil?) ? log : @job.log
    end

  end # class Request

end # module PluginJob
