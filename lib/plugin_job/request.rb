require "plugin_job/outputters/host_echo"
require "Qt"
require "socket"
require "stringio"
require "state_machine"

module PluginJob

  class Request

    attr_reader :connection, :plugins, :job, :pipeline_cmd

    attr_accessor :command
    
    include LogBuilder

    state_machine :state, :initial => :new do 
      
      event :start_setup do
        transition :new => :setting_up
      end

      event :setup_done do 
        transition :setup => :run_ready
      end

      event :begin_run do
        transition :run_ready => :running
      end

      event :kill do
        transition [:new, :setting_up, :run_ready, :running] => :killed
      end

      event :complete_run do
        transition :running => :run_completed
      end

      event :cleanup do
        transition [:run_completed, :killed] => :cleaning
      end

      event :end_cleanup do
        transition :cleaning => :cleaned
      end

      state :new
      state :setting_up
      state :run_ready
      state :running
      state :run_completed
      state :cleaning
      state :cleaned
      state :killed
    end # state_machine

    def initialize(command, controller, connection)
      @command = command
      @controller = controller
      @connection = connection
      @pipeline_cmd = nil
      @plugins = controller.plugins
      init_log(controller.log, "request")
      super() # to initialize the sate machine
    end # initialize

    def setup
      # self.start_setup
      begin
        @job = plugins[command].new(@controller.host)
        @job.setup
      rescue => detail
        connected_log.error I18n.translate('plugin_job.host.error', :message => detail)
        connected_log
          .debug I18n.translate('plugin_job.host.backtrace', 
                                :trace =>  detail.backtrace.join("\r\n"))
      ensure
        # Signal setup complete unless the job was killed
        unless @controller.host.job_cleared?
          @controller.host.setup_complete
        end
      end
      self.setup_done
    end # setup

    def run
      self.begin_run
      if (@passed_validation = @job.valid?)
        begin
          temp_stream = StringIO.new
          begin
            out_stream = $stdout
            $stdout = temp_stream
            @job.run
            @pipeline_cmd = @job.meta[:pipeline_command]
          ensure
            $stdout = out_stream
          end
          connected_log.debug temp_stream.string if temp_stream.string.strip.length > 0
          connected_log.info I18n.translate('plugin_job.host.completed')
        rescue => detail
          connected_log.error I18n.translate('plugin_job.host.error', :message => detail)
          connected_log
            .debug I18n.translate('plugin_job.host.backtrace', 
                                  :trace =>  detail.backtrace.join("\r\n"))
        ensure
          # Signal run complete unless the job was killed
          unless @controller.host.job_cleared?
            @controller.host.run_complete
          end
        end # begin, rescue
      else
        connected_log.warn I18n.translate('plugin_job.host.invalid')
        if !@job.validation_errors.empty?
          @job.validation_errors.each do |msg|
            connected_log.warn msg
          end
        end
        @controller.host.run_complete
      end # job.valid?
      self.complete_run
    end # run

    def meta
      @job.meta
    end

    def connected_log
      (@job.nil? || @job.log.nil?) ? log : @job.log
    end

    def computer_context_info
      # Get computer name info
      # http://www.codeproject.com/Articles/7088/How-to-Get-Windows-Directory-Computer-Name-and-Sys
      # http://newsgroups.derkeiler.com/Archive/Comp/comp.lang.ruby/2008-04/msg01780.html
      # http://www.ruby-forum.com/topic/152169
      "#{command} #{Time.now} #{Socket.gethostname} #{ENV['USERNAME']}"
    end

    def passed_validation?
      @passed_validation
    end

  end # class Request

end # module PluginJob
