module PluginJob

  class TextHost
    
    include LogBuilder
    
    def initialize(command, host, connection)
      @host = host
      @connection = connection
      @command = command
      @plugins = host.plugins
      init_log(host.log, "host")
    end
    
    def launch
      log.info I18n.translate('plugin_job.host.command', :command => @command)
      begin
        if @plugins.has_command?(@command)
          job = @plugins[@command].new(self)
          job.setup
          if job.valid?
            job.run
            log.info I18n.translate('plugin_job.host.completed')
          else
            log.error I18n.translate('plugin_job.host.invalid')
          end
        else
          log.info I18n.translate('plugin_job.host.unknown_command')
        end
      rescue
        log.error I18n.translate('plugin_job.host.error', :message => $!)
      end
    end
    
    def block(command)
      log.warn I18n.translate('plugin_job.host.block', :command => command)
    end

  end # class TextHost
end # module PluginJob
