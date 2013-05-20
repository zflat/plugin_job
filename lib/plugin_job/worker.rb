module PluginJob
  class Worker
    include LogBuilder
    
    attr_reader :host
    
    def initialize(host)
      @host = host
      init_log(host.log, "Worker")
    end
    
    def setup
    end
    
    def valid?
      true
    end

    def run
    end

    def silent?
      false
    end

  end
end
