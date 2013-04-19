require "spec_helper"

module ByRefMethods
  attr_accessor :value
end

module PluginJob

  describe "Object descendent" do

    context "extending module methods" do
      subject(:obj){Object.new.extend ByRefMethods}

      it "is of type object" do
        expect(obj.class).to eq Object
      end
      
      describe "assigning a value" do
        let(:val){ Random.rand(99) }
        before :each do
          obj.value = val
        end
        it "holds what is assigned" do
          expect(obj.value).to eq val
        end
      end
    end # context "extending module methods"
    
  end # describe "Object descendent" do
end

