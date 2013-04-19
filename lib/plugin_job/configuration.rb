module PluginJob

  # Allow for configuration in the host application
  # See http://robots.thoughtbot.com/post/344833329/mygem-configure-block
  class Configuration
    attr_accessor :port, :host_ip
      
    def initialize
      @port = 3333
      @host_ip = "127.0.0.1"
      @output_path = './output.pdf'
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
