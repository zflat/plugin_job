module PluginJob
  class Worker
    include LogBuilder
    
    attr_reader :host, :validation_errors
    
    def initialize(host)
      @host = host
      @validation_errors = []
      init_log(host, "Worker")
    end
    
    def setup
    end
    
    def valid?
      @validation_errors.empty?
    end

    def run
    end

    def meta
      {}
    end

  end
end
