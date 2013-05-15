#!/bin/bash
ruby ./plugin_proc.rb &
sleep 6
telnet localhost 3333
