require "spec_helper"
require "plugin_job/hosts/text_host"

module PluginJob
  describe Dispatcher do
    subject(:server){Dispatcher.new(TextHost, [])}

    it "starts and stops", :if => true do
      EventMachine::run do
        server.start
        EM::stop
      end
    end

  end # describe Dispatcher
end # module PluginJob
