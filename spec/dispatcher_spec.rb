require "spec_helper"
require "plugin_job/hosts/text_host"

module PluginJob
  describe Dispatcher do
    let(:log){Logger.new 'disp_spec'}
    let(:plugins_collection){ Collection.new({}) }
    subject(:server){Dispatcher.new(TextHost, plugins_collection, log, {})}

    it "starts and stops", :if => true do
      EventMachine::run do
        server.start
        EM::stop
      end
    end

  end # describe Dispatcher
end # module PluginJob
