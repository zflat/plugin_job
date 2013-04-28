require "plugin_job/outputters/host_echo"

module PluginJob

  class TextHost
    
    attr_reader :log

    def initialize(command, plugins, connection, log)
      @connection = connection
      @command = command
      @plugins = plugins
      init_log(log)
    end
    
    def launch
      log.info "Command '#{@command}'"
      sleep 5
      begin
        if @plugins.has_command?(@command)
          @plugins[@command].new(self).run
        end
        log.info "Completed"
      rescue
        log.info "An error occurred: #{$!}"
      end
      log.info ">> "
    end
    
    def block(command)
      log.info "Request '#{command}' blocked by an existing job."
    end

    private

    def init_log(parent_log)
      if @log.nil?
        @log = Logger.new("host")
        # inherit the outputters from the dispatcher
        @log.outputters = parent_log.outputters
      end
    end # init_log

  end # class TextHost
end # module PluginJob
