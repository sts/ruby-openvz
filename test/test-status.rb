#!/usr/bin/ruby1.8

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'openvz'

ct = OpenVZ::Container.new("17956")

if ct.running
   puts "Info: Container is running"
end
