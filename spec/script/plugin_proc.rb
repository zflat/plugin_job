#!/usr/bin/env ruby   
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..', 'lib'))

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

require 'plugin_job'

################
# Set up the Log
require "log4r"
include Log4r
log = Logger.new 'dispatcher'
if ARGV.include?('stdout')
  log.outputters = Outputter.stdout
end

####################
# Set up the Plugins
module MyJobs
  class Sleepy < PluginJob::Worker
    def run
      log.warn("starting to count")
      (1..25).to_a.each do |i|
        log.info("..#{i}..")
        sleep 0.1
      end
      log.error("Nothing usefull accomplished.")
    end
  end
  class Print < PluginJob::Worker
    def run
      log.info "Printing output text"
    end
    def meta
      {:silent => true}.merge(super)
    end
  end
  class DelayedPrint < Print
    def run
      sleep(0.1)
      super
    end
  end
  class BadPrint < Print
    def run
      super
      log.error "Bad...print"
    end
  end
  class BadSleep < Sleepy
    def run
      log.error "Bad...sleep"
      super
    end
  end
  class ErrorPrint < Print
    def run
      super
      log.info "Runnin...print"
      1/0
    end
  end
  class NoPrint < Print
    def valid?
      @validation_errors << "Failure by design"
      super
    end
  end
  class HelloBye < PluginJob::Worker
    def meta
      {:silent => true}.merge(super)
    end
    def run
      max_wait = 1
      hello_delay = max_wait*rand
      bye_delay = max_wait*rand

      log.info (hello_delay < bye_delay) ? "Hello" : "Bye"

      hello = Thread.new do
        sleep(hello_delay)
      end
      bye = Thread.new do
        sleep(bye_delay)
        log.info "Canceled"
        top_widget.close
      end
      hello.join
      Thread.kill(bye)
      log.info("Hi")
    end
    def top_widget
      p = widget
      while(p_next = p.parent); p = p_next end
    end
    def widget
      if @widget.nil?
        @widget = Qt::Label.new("Hello form :)")
      end
      @widget
    end
  end
  class Hello < PluginJob::Worker
    class HelloWidget < Qt::Widget
    end
    def run
      log.info "Hello, World!"
    end
    def widget
      if @widget.nil?
        @widget = Qt::Label.new("Hello form :)")
      end
      @widget
    end
  end
end # module MyJobs

plugins = PluginJob::PluginCollection.new({'MainCategory' =>
                                      ['Sleepy', 
                                       'Hello', 
                                       'HelloBye', 
                                       'Print', 
                                       'DelayedPrint', 
                                       'ErrorPrint', 
                                       'BadPrint',
                                       'BadSleep',
                                       'NoPrint'
                                      ]
                                    }, MyJobs)

#######################
# Create the controller
require "plugin_job/hosts/text_host"
require "plugin_job/hosts/gui_host"
require "plugin_job/outputters/host_echo"
class EchoHost < PluginJob::GuiHost
  include PluginJob::HostEcho

  def send_prompt(connection=nil)
    # Given connection takes precedence over defaulted one
    c = connection || @connection
    if c
      r = c.send_data I18n.translate('plugin_job.host.telnet_prompt')
    end
  end

  def block(command, connection=nil)
    super
    if log
      log.warn I18n.translate('plugin_job.host.block', :command => command)
    end
    if connection
      connection.
        send_data I18n.translate('plugin_job.host.block', 
                                 :command => command)+"\r\n"
    end
    send_prompt(connection)
  end
end

controller = PluginJob::HostController.new(EchoHost, plugins, log)

###################
# Set up the server
server_config = {"host_ip" => "localhost", "port" => 3333}
server = PluginJob::Dispatcher.new(controller, server_config)


###############
# Configuration
PluginJob.configure do |config|
  config.base_gem = "plugin_job"
  config.after_update do
    puts "TEST After update"
    log.info "Update completed"
  end
end

#####################
# Run the application
begin
  server.exec_app
rescue => detail
  puts "Plugin host exception."
  puts detail
  puts detail.backtrace.join("\r\n") 
end
