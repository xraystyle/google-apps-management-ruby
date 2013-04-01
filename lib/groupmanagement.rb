#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class GroupManagement
	
	def initialize
		@controller = Controller.current_controller
	end


   def group_prompt

      $stdout.sync = true
      options = ["a","b","c","d","menu"]
      system "clear"
      @controller.print_header("Group Management")
      puts "Options:\n"
      puts "A. List All Groups"
      response = gets.chomp.downcase.strip
      
      while !options.include?(response)
         puts 'Try again. ("A"", "B", "C", "D" or "Menu")'
         print "> "
         response = gets.chomp.downcase.strip
      end
      
      group_action(response)                      
   end


   def group_action(action)
      case action
      when "a"
         list_all_groups
      # when "b"
      #    delete_user
      # when "c"
      #    get_info
      # when "d"
      #    list_all_users
      when "menu"
        system 'clear'
        @controller.prompt
       end
   end


   def list_all_groups

   		group_list = @controller.session.retrieve_all_groups
   		puts "i did something"
   		group_list.each { |e| puts e.group_id  }
   		gets
   		group_prompt
   end





	def timed_out?
    	return false unless @controller.session == nil 
	end





end