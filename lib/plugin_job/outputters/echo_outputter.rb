require "log4r"

module PluginJob

  class EchoOutputter < Log4r::Outputter
    def initialize(name, options={})
      @connection = options[:connection]
      super(name, options)
    end
    
    def write(data)
      @connection.send_data "#{data}"
    end
  end

end
