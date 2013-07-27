require "plugin_job/outputters/host_echo"
require "Qt"
require "socket"
require "stringio"

module PluginJob

  class Request

    attr_reader :connection, :plugins, :job, :pipeline_cmd

    attr_accessor :command
    
    include LogBuilder

    def initialize(command, controller, connection)
      @command = command
      @controller = controller
      @connection = connection
      @pipeline_cmd = nil
      @plugins = controller.plugins
      init_log(controller.log, "request")
    end # initialize

    def setup
      begin
        @job = plugins[@command].new(@controller.host)
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
    end

    def run
      if (@passed_validation = @job.valid?)
        begin
          temp_stream = StringIO.new
          begin
            out_stream = $stdout
            $stdout = temp_stream
            @pipeline_cmd = @job.run
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
          @controller.host.run_complete
      end # job.valid?
    end # run

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
