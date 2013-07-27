require "i18n"
require "plugin_job/configuration"
require "plugin_job/log_builder"
require "plugin_job/worker"
require "plugin_job/dispatcher"
require "plugin_job/request"
require "plugin_job/sig_launch"
require "plugin_job/host_controller"
require "plugin_job/plugin_collection"

require "plugin_job/version"

module PluginJob

  def PluginJob::init
    I18n.load_path << Dir[File.join(File.expand_path(File.dirname(__FILE__) + '/../locales'), '*.yml')]
    I18n.load_path.flatten!
  end

  PluginJob::init

  PluginJob.configure do |config|
  end

end
