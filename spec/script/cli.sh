#!/bin/bash
ruby ./plugin_proc.rb &
sleep 4
telnet localhost 3333
