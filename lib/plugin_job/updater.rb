require "eventmachine"

module PluginJob
  module Updater
    def self.update
      require 'bundler/cli'
      args = ['update', PluginJob.configuration.base_gem]
      if false && PluginJob.configuration.gemfile_path.length > 0
        path_arg = "--path=#{PluginJob.configuration.gemfile_path}"
        args << path_arg
      end
      Bundler::CLI.start(args)
    end

    class UpdateJob < PluginJob:: Worker
      def run
        Updater::update
      end
    end

  end
end
