#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class GroupManagement
	
	def initialize(session)
		@session = session
		@controller = Controller.current_controller
		start_timeout
	end





	def start_timeout
    	timeout=Thread.new {
        	sleep 300
        	@session = nil
        	}
	end

	def timed_out?
    	return false unless @session == nil 
	end





end