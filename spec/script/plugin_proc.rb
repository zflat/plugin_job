#!/usr/bin/env ruby   
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..', 'lib'))

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

require 'plugin_job'
require "plugin_job/hosts/text_host"

plugins = PluginJob::Collection.new({})
host_type = PluginJob::TextHost
server = PluginJob::Dispatcher.new(host_type, plugins)

EM::run do
  server.start
end

