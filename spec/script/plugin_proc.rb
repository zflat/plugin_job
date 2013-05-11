#!/usr/bin/env ruby   
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..', 'lib'))

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

require 'plugin_job'
require "plugin_job/hosts/text_host"
require "plugin_job/outputters/host_echo"

require "plugin_job/hosts/gui_host"
class EchoHost < PluginJob::GuiHost
  include PluginJob::HostEcho
end

module MyJobs
  class Sleepy < PluginJob::Worker
    def run
      sleep 2
    end
  end
end

require 'Qt4'
class AppHost
  attr_reader :app
  def initialize
    @app = app = Qt::Application.new(ARGV)
  end
end

class SigLaunch < Qt::Object
  signals 'sending(QString)'

  def send_sig(arg)
    emit sending(arg)
  end
end

require "log4r"
include Log4r
log = Logger.new 'dispatcher'
if ARGV.include?('stdout')
  log.outputters = Outputter.stdout
end

plugins = PluginJob::Collection.new({'MainCategory' => ['Sleepy']}, MyJobs)
host_type = EchoHost #  PluginJob::TextHost
host = AppHost.new

launcher = SigLaunch.new

server_config = {"host_ip" => "localhost", "port" => 3333}
server = PluginJob::Dispatcher.new(host_type, 
                                   plugins, 
                                   log,
                                   server_config)

EM::run do
  server.start
  launcher.send_sig("TEST")
  EM.add_periodic_timer(0.01) do
    host.app.process_events
  end
end
