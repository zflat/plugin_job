require "Qt"

module PluginJob

  class TextHost < Qt::Object
    
    include LogBuilder

    signals :complete, :kill, "launch(QString)", :setup_complete, :run_complete

    attr_reader :plugins
    
    def initialize
      super

      # Hash containing execution steps
      @steps = {}

      # Synchronize access to killing current job
      @killable_state_lock = Mutex.new
      killable_state_start

      self.connect(SIGNAL("launch(QString)")) { |arg|
        process_request(arg)
      }

      self.connect(SIGNAL :kill){
        if can_kill?
          # end any running steps
          @steps.each do |key, val|
            Thread.kill(val)
          end
          killed
          end_job "kill"
        end
      }

      self.connect(SIGNAL :setup_complete) { after_setup }
      self.connect(SIGNAL :run_complete) { after_run }

    end # initialize

    def command
      @request.command if @request
    end

    def plugins
      @request.plugins
    end

    def valid_job?
      @request.passed_validation?
    end

    def killed?
      ret_val = nil
      @killable_state_lock.synchronize{
        ret_val =  @killed
      }
      ret_val
    end

    def killed
      @killable_state_lock.synchronize{
        @killed = true
      }
    end

    def can_kill?
      killable = nil
      @killable_state_lock.synchronize{
        killable = @active_state
      }
      killable
    end
    
    def killable_state_start
      @killable_state_lock.synchronize{
        @active_state = true
      }
    end

    def killable_state_end
      @killable_state_lock.synchronize{
        @active_state = false
      }
    end
    
    def process_request(arg)
      if arg != ""
        
        killable_state_start
        
        # Run the setup step asynchronisly
        @steps[:setup] = Thread.new {
          @request.setup
        }
      end
    end

    def after_setup
      log.info @request.computer_context_info

      # Execute the Run step asynchronisly
      @steps[:run] = Thread.new {@request.run}
    end

    def after_run
      killable_state_end
      unless killed?
        end_job "after_run"
      end
    end

    def next_job=(request)
      clear_job
      @request = request
      @connection = request.connection
      init_log(request.log, "host")
    end

    def block(command)
      log.warn I18n.translate('plugin_job.host.block', :command => command)
      send_prompt
    end

    def send_prompt(connection=nil)
    end

    def job_cleared?
      @request.nil?
    end

    private

    def clear_job
      @request = nil
      @connection = nil
      @log = nil
    end

    def setup_job
    end

    def end_job(state)
      log.info "End job sent via #{state}"
      emit complete
    end

  end # class TextHost
end # module PluginJob
