module PluginJob
  module Updater
    def self.update
      require 'bundler/cli'
      args = ['update', PluginJob.configuration.base_gem]
      Bundler::CLI.start(args)
    end

    class UpdateJob < PluginJob:: Worker
      def run
        Updater::update
      end
    end

  end
end
