
module PluginJob
  class TextHost
    
    def initialize(command, plugins, connection)
      @connection = connection
      @command = command
      @plugins = plugins
    end
    
    def launch
      log "Command: #{@command}\n"
      sleep 5
      begin
        if @plugins.has_command?(@command)
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
