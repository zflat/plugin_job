#!/usr/bin/env ruby   
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..','..', 'lib'))

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

require 'plugin_job'
require 'plugin_job/hosts/text_host'

module Pkg
end

require "log4r"
include Log4r
log = Logger.new 'proc'
log.outputters = Outputter.stdout

plugins = PluginJob::Collection.new({'MainCategory' => []}, Pkg)


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

server_config = {"host_ip" => "localhost", "port" => 3333}
server = PluginJob::Dispatcher.new(controller, server_config)
server.exec_app
