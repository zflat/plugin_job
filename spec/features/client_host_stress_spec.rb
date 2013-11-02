require "spec_helper"
require "plugin_job/hosts/text_host"

require "childprocess"
require "tempfile"
require "net/telnet"

module PluginJob

  describe "Repeated calls to the dispatcher from multiple clients" do
    let(:dispatcher){ChildProcess.
      build("ruby", File.join(File.dirname(__FILE__), '..','script','plugin_proc.rb'), 'stdout')}
    let(:temp_out){Tempfile.new("client_host_spec_1")}

    # let(:command){"DelayedPrint"}
    let(:command){"HelloBye"}
    before :each do
      # capture output to a temp file
      dispatcher.io.stdout = temp_out
      dispatcher.start
      sleep(2)
    end
    
    it "runs requests and blocks when necessary" do
      expect(dispatcher).to be_alive
      
      n_clients = 5
      arr_client = (1..n_clients).map{[]}
      n_requests =50

      (1..n_requests).to_a.each do |t|      
        (0..n_clients-1).to_a.each do |i|
          arr_client[i] << Thread.new{TelnetClient.new.request(command)}
          sleep(0.1)
        end
      end
      
      arr_client.each do |c|
        c.each do |t|
          t.join
        end
      end
      
      # read output from the temp file
      temp_out.rewind
      output = temp_out.read
      # puts output
      expect(output).to_not be_nil
      expect(output =~ Regexp.new(command)).to_not be_nil
      expect(output =~ Regexp.new("Exception backtrace")).to be_nil
    end
    
    after :each do
      temp_out.close
      temp_out.unlink
      dispatcher.stop
    end
  end # describe "second client making calls to the dispatcher" do

end # module PluginJob
