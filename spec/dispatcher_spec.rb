require "spec_helper"

module PluginJob
  describe Dispatcher do
    subject(:server){Dispatcher.new}

    it "starts and stops", :if => true do
      EventMachine::run do
        server.start
        # EM::stop
      end
    end

  end # describe Dispatcher
end # module PluginJob
