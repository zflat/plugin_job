module PluginJob
  module Updater
    def self.update
      require 'bundler/cli'
      Bundler::CLI.start(['install'])
    end

    class UpdateJob < PluginJob:: Worker
      def run
        Updater::update
      end
    end

  end
end
