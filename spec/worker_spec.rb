require "spec_helper"

module PluginJob
  describe Worker do
    context "with default paramaters" do
      subject(:worker){Worker.new}
      
      it "is valid" do
        expect(worker).to_not be_nil
      end
      
    end # context "with default paramaters"
  end # describe Worker
end # module PluginJob
