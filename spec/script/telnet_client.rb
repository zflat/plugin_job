#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..','..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "net/telnet"

# consider using https://github.com/paddor/em-simple_telnet for the telnet client

localhost = nil
while !localhost
  begin
    localhost = Net::Telnet::new("Host" => "localhost",
                               "Timeout" => false,
                               "Port" => 3333,
                               "Telnetmode" => false)
  rescue
  end
  sleep 0.01
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

    begin
      localhost.cmd({"String" => cmd,
                      "FailEOF" => true,
                      "Match" => Regexp.new("#> ")}) do |c|
        print "#{c}"
      end
    rescue => detail
      puts detail
      puts detail.backtrace.join("\r\n")
      exit 1
    end
  end
  sleep 0.01
end

watcher.kill
localhost.kill
