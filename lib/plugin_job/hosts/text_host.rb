module PluginJob

  class TextHost < Qt::Object
    
    include LogBuilder

    signals :complete, :launch, :kill

    attr_reader :plugins
    
    def initialize
      super

      # Hash containing execution steps
      @steps = {}

      self.connect(SIGNAL :launch) { |arg|
        process_request(arg)
      }

      self.connect(SIGNAL :kill){
        # end any running steps
        @steps.each do |key, val|
          Thread.kill(val)
        end
        end_job
      }
    end # initialize

    def command
      @request.command
    end

    def plugins
      @request.plugins
    end
    
    def process_request(arg)
      # Run the setup step asynchronisly
      @steps[:setup] = Thread.new {
        @request.setup
      }
    end

    def after_setup
      # Get computer name info
      # http://www.codeproject.com/Articles/7088/How-to-Get-Windows-Directory-Computer-Name-and-Sys
      # http://newsgroups.derkeiler.com/Archive/Comp/comp.lang.ruby/2008-04/msg01780.html
      # http://www.ruby-forum.com/topic/152169
      log.info "#{command} #{Time.now} #{Socket.gethostname} #{ENV['USERNAME']}"
      
      # Execute the Run step asynchronisly
      @steps[:run] = Thread.new {@request.run}
    end

    def after_run
      end_job
    end

    def next_job=(request)
      clear_job
      @request = request
      @connection = request.connection
      init_log(request.log, "host")
      
      # Job step callbacks
      @request.after_setup = method(:after_setup)
      @request.after_run = method(:after_run)
    end

    def end_job
      send_prompt
      clear_job
      self.complete
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
