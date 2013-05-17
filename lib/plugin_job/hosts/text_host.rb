module PluginJob

  class TextHost < Qt::Object
    
    include LogBuilder

    signals :complete, :launch
    
    def initialize
      super
      self.connect(SIGNAL :launch) { |arg|
        process_request(arg)
      }
    end # initialize
    
    def process_request(arg)
      @command = @request.command
      @plugins = @request.plugins
      
      # Run the setup step asynchronisly
      @setup_step = Thread.new {
        @request.setup
      }
    end

    def after_setup
      proc {
        # Get computer name info
        # http://www.codeproject.com/Articles/7088/How-to-Get-Windows-Directory-Computer-Name-and-Sys
        # http://newsgroups.derkeiler.com/Archive/Comp/comp.lang.ruby/2008-04/msg01780.html
        # http://www.ruby-forum.com/topic/152169
        log.info "#{@command} #{Time.now} #{Socket.gethostname} #{ENV['USERNAME']}"

        # Execute the Run step asynchronisly
        @run_step = Thread.new { @request.run }
      }
    end

    def after_run
      proc {
        log.info I18n.translate('plugin_job.host.completed')
        send_prompt
        clear_job
        self.complete
      }
    end

    def next_job=(request)
      clear_job
      @request = request
      @connection = request.connection
      init_log(request.log, "host")
      
      # Job step callbacks
      @request.after_setup = after_setup
      @request.after_run = after_run
    end

    def block(command)
      log.warn I18n.translate('plugin_job.host.block', :command => command)
      send_prompt
    end

    def send_prompt
    end

    private

    def clear_job
      @request = nil
      @connection = nil
      @log = nil
    end

    def setup_job
    end

  end # class TextHost
end # module PluginJob
