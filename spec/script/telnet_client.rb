#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "net/telnet"
localhost = nil
while !localhost
  begin
    localhost = Net::Telnet::new("Host" => "localhost",
                               "Timeout" => false,
                               "Port" => 3333,
                               "Telnetmode" => false)
  rescue
  end
end

watcher = Thread.new {
  begin
    localhost.waitfor("FailEOF" => true)
  rescue
    puts "\nConnection closed."
    localhost.close
    exit 0
  end
}

print "#> "
cmd = ""
while cmd
  input = STDIN.gets
  if input
    cmd = input.chomp
    localhost.cmd({"String" => cmd,
                "Match" => Regexp.new("#> ")}) do |c|
      print "#{c}"
    end
  end
end


