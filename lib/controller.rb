#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class Controller

   def initialize
      @auth = LogIn.new
      @session = @auth.gapps_session
      @username = @auth.username
      @created_users = []
      @deleted_users = []
      start_timeout
   end
   
   def run!
      # Start doing shit.
      prompt      
   end
      
   #Get user input to perform actions
   def prompt
         options = ["a","b","c","d"]
         puts "\nOptions:\n"
         puts "A. Create User"
         puts "B. Delete User"
         puts "C. Get A User's Info"
         puts "D. Exit"
         STDOUT.sync = true
         print "> " 
         response = gets.chomp.downcase.strip
         
         while !options.include?(response)
            puts 'Try again. ("A"", "B", "C" or "D")'
            print "> "
            response = gets.chomp.downcase.strip
         end
         
         do_action(response)                      
   end
   
   # Get the action returned from 'prompt'. Clean up the input and pass to appropriate method.
   def do_action(action)
      case action
      when "a"
         create_user
      when "b"
         delete_user
      when "c"
         get_info
      when "d"
         bail
      end
   end
   
   #create a user
   def create_user
      user_data = {}
      default_pass = "changeme456"
      system("clear")
      puts "Create A User\n\n"
      
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
            prompt
         end
         
         @created_users << user_data
         puts "\nUser created successfully:\n"
         puts "#{user_data[:fname].capitalize} #{user_data[:lname].capitalize}\nUsername: #{user_data[:uname]}\n"
         puts "Press enter to continue..."
         gets
         system("clear")
         prompt
         
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
      puts "Create A User\n\n"
      # Get the user to delete.
      print "Enter the username of the user you'd like to delete: "
      response = gets.chomp.strip.downcase
      # Idiot check.
      puts "\nUser #{response} will be deleted. This cannot be un-done, are you sure? (y/n)"
      print "> "
      y_n = gets.chomp.strip.downcase
      
      case y_n
      when "y" || "yes"
         # Check that creds are still valid, then delete the user.
         if timed_out? == false
            #template: delete_user(username)
            begin
               @session.delete_user(response)
            rescue GDataError => e
               puts "User deletion failed, retry."
               puts "errorcode = " +e.code, "input : "+e.input, "reason : "+e.reason
               prompt
            end

            @deleted_users << response
            puts "\nUser deleted successfully:\n"
            puts "#{response}"
            puts "Press enter to continue..."
            gets
            system("clear")
            prompt
         else
            puts "Session timed out, please re-authenticate."
            @auth = LogIn.new(@username)
            @session = @auth.gapps_session
            delete_user
         end
      when "n" || "no"
         puts "/nUser deletion cancelled. No changes have been made.\n"
         prompt
      else
         puts "/nBad input, user deletion cancelled. Try again.\n"
         prompt
      end
         
    
   end
   
   #get user info
   def get_info
      system("clear")
      print "Enter the username you want to retrieve info for: "
      username=gets.chomp.downcase.strip
      
      if timed_out? == false
      # template: retrieve_user(username)
         begin
            user=@session.retrieve_user(username)
         rescue GDataError => e
            puts "User retrieval failed for username \"#{username}\"."
            puts "Reason : "+e.reason
            prompt
         end
         if user
            # Need to clean this up with better text and more of a table-style output. Work in progress.
            puts "\n\nInfo for username #{username}:\n\n"
            puts "First and last name: \n#{user.given_name} #{user.family_name}\n\n"
            puts "User suspended? #{user.suspended}"
            puts "User IP whitelisted? #{user.ip_whitelisted}"
            puts "Is admin? #{user.admin}"
            puts "Must change password on next login? #{user.change_password_at_next_login}"
            puts "Has user logged in yet? #{user.agreed_to_terms}"
            puts "User quota(MB): #{user.quota_limit}\n"
            puts "Press enter to continue..."
            gets
            system("clear")
            prompt
         end
      else
         puts "Session timed out, please re-authenticate."
         @auth = LogIn.new(@username)
         @session = @auth.gapps_session
         get_info
      end

   end
   
   # gtfo
   def bail
   system("clear")
   puts "\n\nThanks for usint xraystyle's GApps User Provisioning Tool!\n\n"
   # output users created in this session.
   if @created_users.any?
      puts "Created Users:\n\n"
      @created_users.each do |user|
         puts "#{user[:fname].capitalize} #{user[:lname].capitalize}\nUsername: #{user[:uname]}\n\n"
      end
   end
   # output users deleted in this session.
   if @deleted_users.any?
      puts "Deleted Users:\n\n"
      @deleted_users.each do |user|
         puts "#{user}\n\n"
      end
   end
   sleep 2
   exit!


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

    # Checks to see if the session auth has timed out. 
    # If it has, the user will have to authenticate again.
   
   def timed_out?
         return false unless @session == nil
   end
   
end