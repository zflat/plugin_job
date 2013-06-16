module PluginJob

  # Allow for configuration in the host application
  # See http://robots.thoughtbot.com/post/344833329/mygem-configure-block
  class Configuration
    attr_accessor :port, :host_ip, :base_gem, :gemfile_path
      
    def initialize
      @port = 3333
      @host_ip = "127.0.0.1"
      @base_gem = "plugin_job"
      @gemfile_path = ""
    end

    def after_update(&block)
      if block
        @after_update_proc = block
      elsif @after_update_proc
        @after_update_proc.call
      end
    end
  end # class Configuration
  
  class << self
    attr_accessor :configuration
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(self.configuration)
  end
  
  def self.reset_configuration
    self.configuration = Configuration.new
  end
end # module PluginJob
