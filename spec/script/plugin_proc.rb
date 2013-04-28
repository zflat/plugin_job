#!/usr/bin/env ruby   
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..', 'lib'))

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

require 'plugin_job'
require "plugin_job/hosts/text_host"
require "plugin_job/outputters/host_echo"

class EchoHost < PluginJob::TextHost
  include PluginJob::HostEcho
end

require "log4r"
include Log4r
log = Logger.new 'dispatcher'
if ARGV.include?('stdout')
  log.outputters = Outputter.stdout
end

plugins = PluginJob::Collection.new({})
host_type = EchoHost #  PluginJob::TextHost
server_config = {"host_ip" => "localhost", "port" => 3333}
server = PluginJob::Dispatcher.new(host_type, 
                                   plugins, 
                                   log,
                                   server_config)


EM::run do
  server.start
end
