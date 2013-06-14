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

  class BadPrint < Print
    def run
      super
      log.error "Bad...print"
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
end
plugins = PluginJob::Collection.new({'MainCategory' =>
                                      ['Sleepy', 
                                       'Hello', 
                                       'Print', 
                                       'BadPrint']
                                    }, MyJobs)

#######################
# Create the controller
require "plugin_job/hosts/text_host"
require "plugin_job/hosts/gui_host"
require "plugin_job/outputters/host_echo"
class EchoHost < PluginJob::GuiHost
  include PluginJob::HostEcho

  def send_prompt(connection=nil)
    c = @connection || connection
    if c
      c.send_data "#> "
    end
  end

  def block(command)
    super
    if log
      log.warn I18n.translate('plugin_job.host.block', :command => command)
    end
  end
end

controller = PluginJob::HostController.new(EchoHost, plugins, log)

###################
# Set up the server
server_config = {"host_ip" => "localhost", "port" => 3333}
server = PluginJob::Dispatcher.new(controller, server_config)

#####################
# Run the application
begin
  server.exec_app
rescue 
  puts "Server not running in this process"
end
