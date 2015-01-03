#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

trap ("INT") {
	if Controller.current_controller.user_manager
		Controller.current_controller.bail
	else
		system("clear")
	    puts "\n\n"
	    puts "Thanks for using GApps User Provisioning!".center(100)
	    puts "\n\n"
	    puts "*" * 100
	    puts "\n\n"
	    sleep 2
	    exit!	
	end
}

APP_ROOT= File.dirname(__FILE__)

$:.unshift(File.join(APP_ROOT, 'lib'))
$:.unshift(File.join(APP_ROOT, 'lib', 'core_ext'))
$:.unshift(File.join(APP_ROOT, 'gappsprovisioning'))

require 'titleize'
require 'text_formatting'
require "io/console"
require 'provisioningapi'
require 'net/https'
require 'login'
require 'controller'
require 'usermanagement'
require 'groupmanagement'
require 'usersetup'
include GAppsProvisioning

system "clear"


controller = Controller.new


system "clear"

controller.run!

exit
