
module PluginJob
  class TextHost
    
    def initialize(command, plugins, connection)
      @connection = connection
      @command = command
      @plugins = plugins # PluginJob.configuration.plugins
    end
    
    def launch
      log "Command: #{@command}\n"
      begin
        sleep 5
        if @plugins.command_list.includes?(@command)
          @plugins[@command].new(self).run
        end
        log "Completed"
      rescue
        log "An error occurred: #{$!}"
      end
      log ">> "
    end
    
    def block(command)
      log "Request '#{command}' blocked by an existing job."
    end

    def log(message)
      @connection.send_data "#{message}\n"
      puts message
    end
    
  end
end
