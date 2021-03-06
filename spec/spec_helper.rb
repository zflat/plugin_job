$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec'
require 'plugin_job'
require 'log4r'

include Log4r

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

module PluginJob
  class TelnetClient
    def initialize
      args = {"Host" => "localhost",
        "Timeout" => 10,
        "Telnetmode" => false,
        "Port" => 3333}
      @connection = Net::Telnet::new(args)
    end

    def request(command)
      p_matcher = Regexp.new("#{I18n.translate('plugin_job.host.completed')}|#{I18n.translate('plugin_job.host.telnet_prompt')}")
      cmd({"String" => command, "Match" => p_matcher}) do |c|
        # puts c
      end
    end

    def cmd(args, &block)
      @connection.cmd(args){ |c| yield(c)}
      #begin
      #  @connection.cmd(args){ |c| yield(c)}
      #rescue => detail
      #  yield detail
      #end
    end
  end # class TelnetClient
end # module PluginJob

RSpec.configure do |config|

  # Testing CLI
  # See 
  # https://github.com/docwhat/homedir/blob/homedir3/spec/spec_helper.rb
  # https://github.com/docwhat/homedir/blob/homedir3/spec/lib/homedir/cli_spec.rb
  # https://github.com/wycats/thor/blob/master/spec/thor_spec.rb
  # http://stackoverflow.com/questions/12673485/how-to-test-stdin-for-a-cli-using-rspec
  # Different implementation for #capture
  # http://rails-bestpractices.com/questions/1-test-stdin-stdout-in-rspec

  # Captures the output for analysis later
  #
  # @example Capture `$stderr`
  #
  #     output = capture(:stderr) { $stderr.puts "this is captured" }
  #
  # @param [Symbol] stream `:stdout` or `:stderr`
  # @yield The block to capture stdout/stderr for.
  # @return [String] The contents of $stdout or $stderr
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  # Silences the output stream
  #
  # @example Silence `$stdout`
  #
  #     silence(:stdout) { $stdout.puts "hi" }
  #
  # @param [IO] stream The stream to use such as $stderr or $stdout
  # @return [nil]
  alias :silence :capture

end
