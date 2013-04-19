require "spec_helper"

module PluginJob
  describe Configuration do
    context "without modificatios" do
      subject(:config){PluginJob.configuration}

      it "has a port" do
        expect(config.port).to_not be_nil
      end
    end # context "without modificatios"
    
  end # describe Configuration 
end # module PluginJob
