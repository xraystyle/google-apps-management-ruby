#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

include GAppsProvisioning

class UserManagement

	attr_accessor :created_users, :deleted_users

	def initialize(session)
		@session = session
		@controller = Controller.current_controller
		@created_users = []
		@deleted_users = []
		@fulluserlist = nil
		start_timeout
	end

   def user_prompt

      $stdout.sync = true
      options = ["a","b","c","d","menu"]
      system "clear"
      @controller.print_header("User Management")
      puts "Options:\n"
      puts "A. Create User"
      puts "B. Delete User"
      puts "C. Get User Info"
      puts "D. List All Users\n\n"
      puts "To go back to the main menu, type \"Menu\""
      print "> " 
      response = gets.chomp.downcase.strip
      
      while !options.include?(response)
         puts 'Try again. ("A"", "B", "C", "D" or "Menu")'
         print "> "
         response = gets.chomp.downcase.strip
      end
      
      user_action(response)                      
   end

   def user_action(action)
      case action
      when "a"
         create_user
      when "b"
         delete_user
      when "c"
         get_info
      when "d"
         list_all_users
      when "menu"
          @controller.prompt
       end
   end


   #create a user
   def create_user
      user_data = {}
      default_pass = "changeme456"
      system("clear")
      puts "\n\nCreate A User\n\n"
      puts "*" * 80
      puts "\n\n"

      print "Enter the new user's first name: "
      user_data[:fname] = gets.chomp.strip.capitalize
      
      print "Enter the new user's last name: "
      user_data[:lname] = gets.chomp.strip.capitalize
      
      print "Enter the new user's username: "
      user_data[:uname] = gets.chomp.strip.downcase
      
      puts "\nThe user will be assigned the default password of #{default_pass}"
      puts "and it must be changed on their first login.\n"
      
      # You can specify your preferred default password using the 'default_pass' 
      # variable assignment at the beginning of this method definition. It's currently
      # set to 'changeme456'. The ability to specify a password was not implemented due
      # to the need for a user to change their password on first login by default, which
      # is more secure than setting a password and notifying the user anyway.
      
      if timed_out? == false
         #template: create_user(username, given_name, family_name, password, passwd_hash_function=nil, quota=nil)
         begin
            @session.create_user(user_data[:uname], user_data[:fname], user_data[:lname], default_pass)
         rescue GDataError => e
            puts "User creation failed, retry."
            puts "errorcode = " +e.code, "input : "+e.input, "reason : "+e.reason
            user_prompt
         end
         
         @created_users << user_data
         puts "\nUser created successfully:\n"
         puts "#{user_data[:fname].capitalize} #{user_data[:lname].capitalize}\nUsername: #{user_data[:uname]}\n"
         puts "Press enter to continue..."
         gets
         system("clear")
         user_prompt
         
      else
         puts "Session timed out, please re-authenticate."
         @auth = LogIn.new(@username)
         @session = @auth.gapps_session
         create_user
      end
   end
   
   #delete a user
   def delete_user
      system("clear")
      puts "\n\nDelete A User\n\n"
      puts "*" * 80
      puts "\n\n"
      # Get the user to delete.
      print "Enter the username of the user you'd like to delete: "
      response = gets.chomp.strip.downcase
      # Idiot check.
      puts "\nUser #{response} will be deleted. This cannot be un-done, are you sure? (y/n)"
      print "> "
      y_n = gets.chomp.strip.downcase
      
      case y_n
      when "y", "yes"
         # Check that creds are still valid, then delete the user.
         if timed_out? == false
            #template: delete_user(username)
            begin
               @session.delete_user(response)
            rescue GDataError => e
               puts "User deletion failed for user \"#{response}\"."
               puts "Reason : "+e.reason
               user_prompt
            end

            @deleted_users << response
            puts "\nUser deleted successfully:\n"
            puts "#{response}"
            puts "Press enter to continue..."
            gets
            system("clear")
            user_prompt
         else
            puts "Session timed out, please re-authenticate."
            @auth = LogIn.new(@username)
            @session = @auth.gapps_session
            delete_user
         end
      when "n", "no"
         puts "/nUser deletion cancelled. No changes have been made.\n"
            puts "Press enter to continue..."
            gets
            system("clear")
         user_prompt
      else
         puts "/nBad input, user deletion cancelled. Try again.\n"
            puts "Press enter to continue..."
            gets
            system("clear")
         user_prompt
      end
   end
   
   #get user info
   def get_info
      system("clear")
      puts "\n\nRetrieve User Info\n\n"
      puts "*" * 80
      puts "\n\n"
      print "Enter the username you want to retrieve info for: "
      username=gets.chomp.downcase.strip
      
      if timed_out? == false
      # template: retrieve_user(username)
         begin
            user=@session.retrieve_user(username)
            nicks=@session.retrieve_nicknames(username)
            groups=@session.retrieve_groups(username)
         rescue StandardError => e
            puts "User retrieval failed for username \"#{username}\"."
            if e.to_s.include? "undefined"
               puts "Reason : User not found."
            end
            puts "Press enter to continue..."
            gets
            system("clear")
            user_prompt
         end
         
         if user
            output_user_table(user,nicks,groups)
            puts "\n\nPress enter to continue..."
            gets
            system("clear")
            user_prompt
         end
      
      else
         puts "Session timed out, please re-authenticate."
         @auth = LogIn.new(@username)
         @session = @auth.gapps_session
         get_info
      end
   end
   
   # Outputs a cleanly formatted table with the information about a user in the domain.
   # Feel free to comment out any of the lines for info you don't need.
   # For instance, I have zero use for 'ip_whitelisted' and 'quota'.
   def output_user_table(retrieved_user,retrieved_nics=nil,retrieved_groups=nil)
      puts "*" * 80
      puts "Info for username --#{retrieved_user.username}--\n\n"
      puts "First and last name:".ljust(40) + "#{retrieved_user.given_name} #{retrieved_user.family_name}\n".ljust(40)
      
      if retrieved_nics
         first_print = 0
         print "Nicknames:".ljust(40)
         retrieved_nics.each do |nick|
            if first_print == 0
               puts nick.nickname
               first_print += 1
            else 
               puts " ".ljust(40) + nick.nickname.ljust(40)
            end
         end
         puts
      end
      
      if retrieved_groups
         first_print = 0
         print "Groups:".ljust(40)
         retrieved_groups.each do |group|
            if first_print == 0
               puts group.group_id
               first_print += 1
            else 
               puts " ".ljust(40) + group.group_id.ljust(40)
            end
         end
         puts
      end

      puts "User suspended?".ljust(40) + retrieved_user.suspended.ljust(40)
      # puts "User IP whitelisted?".ljust(40) + retrieved_user.ip_whitelisted.ljust(40)
      puts "Is admin?".ljust(40) + retrieved_user.admin.ljust(40)
      puts "Must change password on next login?".ljust(40) + retrieved_user.change_password_at_next_login.ljust(40)
      puts "Has user logged in yet?".ljust(40) + retrieved_user.agreed_to_terms.ljust(40)
      # puts "User quota in MB:".ljust(40) + retrieved_user.quota_limit.ljust(40)
   end
   
   def output_userlist
      if !@fulluserlist
         @fulluserlist = @session.retrieve_all_users
      end
      puts "User list retrieved. How would you like to display?"
      puts "A. Usernames Only"
      puts "B. Full User Info\n\n"
      puts "Note: Full user info does not list nicknames or group membership. \nGet info for a specific user to see nicks and groups for a user.\n"
      print "> "
      a_b = gets.chomp.strip.downcase
      case a_b
      when "a"
         num = 1
         line_toggler = 0
         puts 
         puts "*" * 80
         puts "\nUsernames for this domain:\n\n"
         @fulluserlist.each do |user|
            case line_toggler.even?
            when true 
               print "#{num}. #{user.username}".ljust(40)
               num += 1
               line_toggler += 1
            when false
               puts "#{num}. #{user.username}".ljust(40)
               num += 1
               line_toggler += 1
            end
         end
         puts "\n"
         puts "*" * 80
      when "b"
         puts
         @fulluserlist.each do |user|
            output_user_table(user)
         end
         puts "*" * 80
      end
   end

   def list_all_users
      if !@fulluserlist
         system("clear")
         puts "\n\nList All Users\n\n"
         puts "*" * 80
         puts "\n\n"
         puts "Retreiving all users for a domain can take a long time depending on "
         puts "the number of users but only needs to be retrieved once per session."
         puts "Do you want to continue?(y/n)"
         print "> "
         y_n = gets.chomp.strip.downcase
         case y_n
         when "n", "no"
            puts "User listing cancelled."
            $stdout.sync = true
            5.times do
               putc('.')
               sleep(0.3)
            end
            system("clear")
            user_prompt
         when "y", "yes"
            if timed_out? == false
               output_userlist
               puts "\nPress \"Enter\" to continue..."
               gets
               system("clear")
               user_prompt
            else
               puts "Session timed out, please re-authenticate."
               @auth = LogIn.new(@username)
               @session = @auth.gapps_session
               list_all_users
            end
         else
            puts "Bad input, user listing cancelled."
            puts "Press \"Enter\" to continue..."
            gets
            system("clear")
            user_prompt
         end
      else
         output_userlist
         puts "\nPress \"Enter\" to continue..."
         gets
         system("clear")
         user_prompt
      end
   end

      #### Start Timeout ####


   # start_timeout spins off a new thread that sleeps
   # for 5 minutes, then sets the user's authenticated session
   # back to nil. This prevents the user's password from being
   # stored indefinetly while the app is running.

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