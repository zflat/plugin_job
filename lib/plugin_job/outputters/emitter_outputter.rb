require "log4r"
require "Qt"

module PluginJob

  class EmitterOutputter < Log4r::Outputter
    class Emitter < Qt::Widget
      signals "log(QString)"
    end
    
    attr_reader :emitter

    def initialize(name, options={})
      @emitter = Emitter.new
      super(name, options)
    end

    def write(data)
      @emitter.log(data)
    end
  end # class QtPlainTextOutputter < Log4r::Outputter

end # PluginJob
