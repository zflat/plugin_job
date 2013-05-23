require "log4r"

module PluginJob

  class FlagOutputter < Log4r::Outputter

    class Emitter < Qt::Object
      signals :flag
    end

    attr_reader :flag, :emitter

    def initialize(name, options={})
      @flag = false
      @emitter = Emitter.new
      super(name, options)
    end
    
    def write(data)
      @flag = true
      @emitter.flag
    end
  end

end
