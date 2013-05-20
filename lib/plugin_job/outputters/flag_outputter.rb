require "log4r"

module PluginJob

  class FlagOutputter < Log4r::Outputter
    attr_reader :flag

    def initialize(name, options={})
      @flag = false
      super(name, options)
    end
    
    def write(data)
      @flag = true
    end
  end

end
