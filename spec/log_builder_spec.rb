require "spec_helper"

module PluginJob

  class DemoLogger
    include LogBuilder
    def initialize(parent_logger)
      init_log(parent_logger, "DemoLogger")
    end
  end # class DemoLogger


  describe LogBuilder do
    context "Given nil parent" do
      subject(:logged){DemoLogger.new(nil)}

      it "has a log" do
        expect(logged.log).to_not be_nil
      end
    end # context "Given nil parent"
  end # describe LogBuilder
end
