require "log4r"

module PluginJob

  class QtPlainTextOutputter < Log4r::Outputter
    def initialize(name, options={})
      @widget = options[:widget]
      super(name, options)
    end

    def write(data)
      @widget.appendPlainText(data)
    end
  end # class QtPlainTextOutputter < Log4r::Outputter

end # PluginJob
