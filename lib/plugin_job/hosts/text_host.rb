
module PluginJob

  class TextHost
    attr_reader :log

    def initialize(command, plugins, connection, log)
      @connection = connection
      @command = command
      @plugins = plugins
      @log = log
    end
    
    def launch
      log.info "Command: #{@command}\n"
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

#    def log(message)
#      @connection.send_data "#{message}\n"
#      puts message
#    end
    
  end
end
