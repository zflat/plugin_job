require "spec_helper"
require "plugin_job/hosts/text_host"

require "childprocess"
require "tempfile"
require "net/telnet"

module PluginJob

  describe "client making calls to the dispatcher" do
    let(:dispatcher){ChildProcess.
      build("ruby", File.join(File.dirname(__FILE__), '..','script','plugin_proc.rb'), 'stdout')}
    let(:temp_out){Tempfile.new("client_host_spec_0")}
    let(:client){Net::Telnet::new("Host" => "localhost",
                                  "Timeout" => 10,
                                  "Telnetmode" => false,
                                  "Port" => 3333
                                )}

    let(:command){"Sleepy"}
    before :each do
      # capture output to a temp file
      dispatcher.io.stdout = temp_out
      dispatcher.start
      sleep(2)
    end
    
    it "responds with an echo" do
      expect(dispatcher).to be_alive
      client.cmd({"String" => command, 
                   "Match" => Regexp.new(I18n.translate('plugin_job.host.completed'))}) do |c|
        puts c
      end

      temp_out.rewind
      output = temp_out.read
      # read output from the temp file
      puts output
      expect(output).to_not be_nil
      expect(output =~ Regexp.new(command)).to_not be_nil
    end

    after :each do
      temp_out.close
      temp_out.unlink
      dispatcher.stop
    end
    
  end

end
