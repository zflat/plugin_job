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
      sleep 10
    end
  end
end

require 'Qt4'

class SigLaunch < Qt::Object
  signals 'run(QString)', 'stop()'

  def initialize
    super
    self.connect(SIGNAL("run(QString)")) do |arg|
      @window = Qt::Widget.new()
      @window.resize(200, 120)
      @window.show()
      $qApp.process_events
    end
    
    self.connect(SIGNAL("stop()")) do
      @window.close
    end
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
launch_sender = SigLaunch.new

server_config = {"host_ip" => "localhost", "port" => 3333}
launcher = PluginJob::HostController.new(host_type, plugins, log, launch_sender)

server = PluginJob::Dispatcher.new(launcher, server_config)

app = Qt::Application.new(ARGV)
EM::run do
  server.start
  EM.add_periodic_timer(0.01) do
    app.process_events
  end
end
