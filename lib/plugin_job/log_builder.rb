require "log4r"

module PluginJob

  module LogBuilder
    
    def self.included(base)
      base.send(:attr_reader, :log)
    end

    private
    
    # Call init_log from the initializer
    # in the class that includes this module
    def init_log(parent_log, name)
      if @log.nil?
        @log = Logger.new(name)
        # inherit the outputters from the parent log
        @log.outputters = parent_log.outputters
      end
    end # init_log

  end # module LogBuilder
end # module PluginJob
