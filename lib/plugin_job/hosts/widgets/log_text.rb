require "Qt"

module PluginJob

  class LogTextPage < Qt::Widget
    attr_reader :text_area
    def initialize(parent=nil)
      super(parent)
      @layout = Qt::VBoxLayout.new(self)
      @text_area = LogText.new(self)
      self.setSizePolicy(Qt::SizePolicy.new(Qt::SizePolicy::Ignored, Qt::SizePolicy::Ignored))
    end # initialize
  end # class LogTextPage

  class LogText < Qt::PlainTextEdit
    attr_reader :text_area

    def initialize(parent=nil)
      super(parent)
      self.setCursorWidth(8)
      self.setReadOnly(true)
      # self.setSizePolicy(Qt::SizePolicy.new(Qt::SizePolicy::Ignored, Qt::SizePolicy::Ignored))
      self.setSizePolicy(Qt::SizePolicy::Expanding, Qt::SizePolicy::Expanding)
      self.resize(200, 200)      
      @text_area = self
    end
  end
end
