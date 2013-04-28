require "plugin_job/outputters/host_echo"

module PluginJob

  class TextHost
    
    include LogBuilder
    
    def initialize(command, plugins, connection, log)
      @connection = connection
      @command = command
      @plugins = plugins
      init_log(log, "host")
    end
    
    def launch
      log.info I18n.translate('plugin_job.host.command', :command => @command)
      sleep 5
      begin
        if @plugins.has_command?(@command)
          @plugins[@command].new(self).run
        end
        log.info I18n.translate('plugin_job.host.completed')
      rescue
        log.error I18n.translate('plugin_job.host.completed', :message => $!)
      end
    end
    
    def block(command)
      log.warn I18n.translate('plugin_job.host.block', :command => @command)
    end

  end # class TextHost
end # module PluginJob
