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
      @fulluserlist = nil
      start_timeout
   end
   
   def run!
      # Start doing shit.
      prompt      
   end
      
   #Get user input to perform actions
   def prompt
      $stdout.sync = true
      options = ["a","b","c","d","quit","exit"]
      puts "\nOptions:\n"
      puts "A. Create User"
      puts "B. Delete User"
      puts "C. Get A User's Info"
      puts "D. List All Users\n\n"
      puts "To exit, type \"quit\", or \"exit\""
      print "> " 
      response = gets.chomp.downcase.strip
      
      while !options.include?(response)
         puts 'Try again. ("A"", "B", "C", "D" or "quit")'
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
         list_all_users
      when "quit", "exit"
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
      when "y", "yes"
         # Check that creds are still valid, then delete the user.
         if timed_out? == false
            #template: delete_user(username)
            begin
               @session.delete_user(response)
            rescue GDataError => e
               puts "User deletion failed for user \"#{response}\"."
               puts "Reason : "+e.reason
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
      when "n", "no"
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
            output_user_table(user)
            puts "\n\nPress enter to continue..."
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
   
   # Outputs a cleanly formatted table with the information about a user in the domain.
   # Feel free to comment out any of the lines for info you don't need.
   # For instance, I have zero use for 'ip_whitelisted' and 'quota'.
   def output_user_table(retrieved_user)
      puts "*" * 80
      puts "Info for username --#{retrieved_user.username}--\n\n"
      puts "First and last name:".ljust(40) + "#{retrieved_user.given_name} #{retrieved_user.family_name}".ljust(40)
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
      puts "B. Full User Info"
      print "> "
      a_b = gets.chomp.strip.downcase
      case a_b
      when "a"
         puts 
         puts "*" * 80
         @fulluserlist.each do |user|
            puts user.username
         end
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
         puts "Retreiving all users for a domain can take a long time \ndepending on the number of users.\n\nDo you want to continue? (y/n)"
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
            prompt
         when "y", "yes"
            output_userlist
            puts "\nPress \"Enter\" to continue..."
            gets
            system("clear")
            prompt
         end
      else
         output_userlist
         puts "\nPress \"Enter\" to continue..."
         gets
         system("clear")
         prompt
      end

   end

   # gtfo
   def bail
      system("clear")
      puts "\n\n"
      puts "Thanks for using xraystyle's GApps User Provisioning Tool!".center(80)
      puts "\n\n"
      puts "*" * 80
      puts "\n\n"
      # output users created in this session.
      if @created_users.any?
         puts "Created Users:\n\n"
         @created_users.each do |user|
            puts "#{user[:fname].capitalize} #{user[:lname].capitalize}\nUsername: #{user[:uname]}\n\n"
         end
         puts "-" * 80 + "\n"
      end
      # output users deleted in this session.
      if @deleted_users.any?
         puts "Deleted Users:\n\n"
         @deleted_users.each do |user|
            puts "#{user}\n\n"
         end
         puts "-" * 80 + "\n"
      end
      sleep 1
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

   def timed_out?
      return false unless @session == nil 
   end

   
end

















