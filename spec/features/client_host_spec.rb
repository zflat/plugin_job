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
    let(:client){TelnetClient.new}

    let(:command){"Sleepy"}
    before :each do
      # capture output to a temp file
      dispatcher.io.stdout = temp_out
      dispatcher.start
      sleep(2)
    end
    after :each do
      temp_out.close
      temp_out.unlink
      dispatcher.stop
    end

    it "responds with an echo" do
      expect(dispatcher).to be_alive
      client.request(command)

      temp_out.rewind
      # read output from the temp file
      output = temp_out.read
      # puts output
      expect(output).to_not be_nil
      expect(output =~ Regexp.new(command)).to_not be_nil
      expect(output =~ Regexp.new("Completed")).to_not be_nil
    end
  end #   describe "client making calls to the dispatcher" do

  describe "Invalid preconditions" do
    let(:dispatcher){ChildProcess.
      build("ruby", File.join(File.dirname(__FILE__), '..','script','plugin_proc.rb'), 'stdout')}
    let(:temp_out){Tempfile.new("client_host_spec_1")}
    let(:client){TelnetClient.new}
    let(:second_client){TelnetClient.new}
    
    let(:command){"NoPrint"}
    before :each do
      # capture output to a temp file
      dispatcher.io.stdout = temp_out
      dispatcher.start
      sleep(2)
    end
    after :each do
      temp_out.close
      temp_out.unlink
      dispatcher.stop
    end

    it "Indicates an error" do
      expect(dispatcher).to be_alive
      client.request(command)

      # read output from the temp file
      temp_out.rewind
      output = temp_out.read
      
      # puts output
      expect(output).to_not be_nil
      expect(output =~ Regexp.new(command)).to_not be_nil
      
      str_invalid = I18n.translate('plugin_job.host.invalid')
      str_err_msg = "Failure by design"
      expect(output =~ Regexp.new(str_invalid)).to_not be_nil
      expect(output =~ Regexp.new(str_err_msg)).to_not be_nil
      expect(output =~ Regexp.new("Exception backtrace")).to be_nil
    end
  end # describe "Invalid preconditions"

  describe "second client making calls to the dispatcher" do
    let(:dispatcher){ChildProcess.
      build("ruby", File.join(File.dirname(__FILE__), '..','script','plugin_proc.rb'), 'stdout')}
    let(:temp_out){Tempfile.new("client_host_spec_1")}
    let(:client){TelnetClient.new}
    let(:second_client){TelnetClient.new}
    
    let(:command){"Sleepy"}
    before :each do
      # capture output to a temp file
      dispatcher.io.stdout = temp_out
      dispatcher.start
      sleep(2)
    end
    
    it "blocks a second request" do
      expect(dispatcher).to be_alive      
      c1 = Thread.new {client.request(command)}
      sleep(0.5)
      c2 = Thread.new {second_client.request(command)}

      c1.join
      c2.join

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
