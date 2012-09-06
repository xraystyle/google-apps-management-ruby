#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

APP_ROOT= File.dirname(__FILE__)

$:.unshift(File.join(APP_ROOT, 'lib'))
$:.unshift(File.join(APP_ROOT, 'gappsprovisioning'))

require 'rubygems'
require 'highline/import'
require 'provisioningapi'
require 'net/https'
require 'login'
require 'controller'
include GAppsProvisioning

system "clear"

puts "\n\n"
puts "xraystyle's GApps User Provisioning Tool".center(80)
puts "\n\n"
puts "*" * 80
puts "\n\n"

controller = Controller.new

controller.run!

exit
