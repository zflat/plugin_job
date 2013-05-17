#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "net/telnet"

localhost = Net::Telnet::new("Host" => "localhost",
                               "Timeout" => 10000,
                               "Port" => 3333,
                               "Telnetmode" => false)

print "#> "
cmd = ""
while cmd != 'exit'

  cmd = STDIN.gets.chomp
  localhost.cmd({"String" => cmd,
                "Match" => Regexp.new("#> ")}) do |c|
    print "#{c}"
  end

end

localhost.close
