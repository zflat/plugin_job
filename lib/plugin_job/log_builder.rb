require "log4r"

module PluginJob

  module LogBuilder
    
    #def self.included(base)
    #  base.send(:attr_reader, :log)
    #end

    def log
      if @log.nil?
        @log = Logger.new('')
      end
      @log
    end

    private
    
    # Call init_log from the initializer
    # in the class that includes this module
    def init_log(parent, name)
      parent_log = nil

      if parent && parent.respond_to?(:log)
        parent_log = parent.log
      elsif parent && parent.respond_to?(:outputters)
        parent_log = parent
      end

      @log = Logger.new(name)
      # inherit the outputters from the parent log
      @log.outputters = parent_log && parent_log.outputters
    end # init_log

  end # module LogBuilder
end # module PluginJob
