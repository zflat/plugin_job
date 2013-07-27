module PluginJob
  module Updater

    def self.check_outdated(job)
      require 'bundler/cli'

      target = PluginJob.configuration.base_gem
      check_args =  ['outdated', PluginJob.configuration.base_gem]

      current_spec = Bundler.load.specs[target].sort_by{ |b| b.version }.last
      definition = Bundler.definition(:gems => [target])
      active_spec = definition.index[target].sort_by{ |b| b.version }.last

      gem_outdated = Gem::Version.new(active_spec.version) > Gem::Version.new(current_spec.version)
      git_outdated = (current_spec.git_version && active_spec.git_version) && 
        current_spec.git_version != active_spec.git_version
      
      return (gem_outdated || git_outdated)
    end

    def self.update(job)
      require 'bundler/cli'
      job.log.info I18n.translate('plugin_job.update.started')
      update_args = ['update', PluginJob.configuration.base_gem]
      Bundler::CLI.start(update_args)
      PluginJob.configuration.after_update
    end

    class UpdateJob < PluginJob:: Worker
      def run
        Updater::update self
      end

      def setup
        if !(@is_outdated = Updater::check_outdated self)
          log.info I18n.translate('plugin_job.update.not_needed')
        end
      end

      def valid?
        @is_outdated
      end

      def meta
        {:pipeline_command => 'Exit'}.merge(super)
      end
    end

  end
end
