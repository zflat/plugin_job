#!/usr/bin/env ruby   
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..', 'lib'))

# Load the bundled environment
require 'rubygems'
require 'bundler/setup'

require 'plugin_job'
require "plugin_job/hosts/text_host"

server = PluginJob::Dispatcher.new(PluginJob::TextHost, [])

EM::run do
  server.start
end

