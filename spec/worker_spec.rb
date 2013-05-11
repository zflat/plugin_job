require "spec_helper"
module PluginJob
  describe Worker do
    context "with default paramaters" do
      subject(:worker){Worker.new nil}
      
      it "is valid" do
        expect(worker).to_not be_nil
        expect(worker).to be_valid
      end
      
      it "can run" do
        expect(worker.respond_to?(:run)).to be_true
      end
      
    end # context "with default paramaters"
  end # describe Worker
end # module PluginJob
