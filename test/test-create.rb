#!/usr/bin/ruby1.8

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'openvz'

ct = OpenVZ::Container.new("123456")

puts "» Creating new virtual machine ---------------------------"
ct.create( :config => "vps.unlimited", :deboostrap => { :dist => "squeeze", :mirror => "http://cdn.debian.net/debian" })

puts "» Setting values -----------------------------------------"
ct.set :hostname => "server01.example.com", :ipadd => "192.168.1.11"
ct.set :nameserver => "192.168.1.2", :searchdomain => "example.com"
ct.set :cpus => 1

puts "» Copying scripts ----------------------------------------"
ct.cp_into :src => "ext/puppetize.sh", :dst => "root/puppetize.sh"

puts "» Starting -----------------------------------------------"
ct.start

puts "» Puppetizing --------------------------------------------"
ct.exec "/root/puppetize.sh"

if ct.running?
   puts "Info: Container is running"

   puts "» Stopping virtual machine -------------------------------"
   ct.stop
   
   puts "» Destroying virtual machine -----------------------------"
   ct.destroy
end
