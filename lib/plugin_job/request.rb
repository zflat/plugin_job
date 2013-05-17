require "plugin_job/outputters/host_echo"
require "Qt"
require "socket"

module PluginJob

  class Request
    attr_reader :command, :connection, :plugins
    attr_accessor :after_setup, :after_run
    
    include LogBuilder

    def initialize(command, controller, connection)
      @command = command
      @controller = controller
      @connection = connection
      @plugins = controller.plugins
      init_log(controller.log, "request")
    end # initialize

    def setup
      @job = plugins[@command].new(@controller.host)
      @job.setup
      
      # Get computer name info
      # http://www.codeproject.com/Articles/7088/How-to-Get-Windows-Directory-Computer-Name-and-Sys
      # http://newsgroups.derkeiler.com/Archive/Comp/comp.lang.ruby/2008-04/msg01780.html
      # http://www.ruby-forum.com/topic/152169
      log.info "#{@command} #{Time.now} #{Socket.gethostname} #{ENV['USERNAME']}"
      # Signal setup complete
      after_setup.call      
    end

    def run
      @job.run
      # Signal run complete
      after_run.call
    end

  end # class Request

end # module PluginJob
