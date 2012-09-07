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
require 'usermanagement'
include GAppsProvisioning

system "clear"

controller = Controller.new

system "clear"

controller.run!

exit
