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
      sleep 10
    end
  end
end
plugins = PluginJob::Collection.new({'MainCategory' => ['Sleepy']}, MyJobs)

#######################
# Create the controller
require "plugin_job/hosts/text_host"
require "plugin_job/hosts/gui_host"
require "plugin_job/outputters/host_echo"
class EchoHost < PluginJob::GuiHost
  include PluginJob::HostEcho

  def send_prompt
    if @connection
      @connection.send_data "#> "
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
server.exec_app
