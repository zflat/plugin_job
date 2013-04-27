require "spec_helper"

module PluginJob
  describe Collection do
    context "with an empty mapping" do
      subject(:collection){Collection.new({})}

      it "has an empty command list" do
        expect(collection.command_list).to be_empty
      end
    end # context "with a nil mapping"
    
  end
end
