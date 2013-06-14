#!/bin/bash
ruby ./plugin_proc.rb &

# telnet localhost 3333
ruby ./telnet_client.rb
