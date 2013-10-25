require "spec_helper"

module PluginJob
  describe PluginCollection do
    context "with an empty mapping" do
      subject(:collection){PluginCollection.new({}, Object)}

      it "has default command update command" do
        expect(collection.command_list).to_not be_empty
        expect(collection.command_list.index(collection.update_cmd)).
          to_not be_nil
      end

      it "has default command update ''" do
        expect(collection.command_list).to_not be_empty
        expect(collection.command_list.index('')).
          to_not be_nil
      end

      it "recognized the empty  string command" do
        expect(collection.recognize_command?('')).to be_true
      end
    end # context "with an empty mapping"
    
  end
end
