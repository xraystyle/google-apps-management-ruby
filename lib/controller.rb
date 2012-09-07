#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class Controller

####### Class Variables/Class Methods #######
   @@current_controller = nil

   def self.current_controller
      @@current_controller
   end
#############################################


############# Instance Methods ##############

   def initialize
      print_header
      @auth = LogIn.new
      @session = @auth.gapps_session
      @username = @auth.username
      @@current_controller = self
      @user_manager = UserManagement.new(@session)
      # @created_users = []
      # @deleted_users = []
      # @fulluserlist = nil
      # start_timeout
   end
   
   def run!
      # Start doing shit.
      prompt      
   end

   def print_header
      puts "\n\n"
      puts "xraystyle's GApps User Provisioning Tool".center(80)
      puts "\n\n"
      puts "*" * 80
      puts "\n\n"
   end

   #Get user input to perform actions
   def prompt

      $stdout.sync = true
      options = ["a","b","c","d","quit","exit"]
      print_header
      puts "Options:\n"
      puts "A. Create User"
      puts "B. Delete User"
      puts "C. Get User Info"
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
         @user_manager.create_user
      when "b"
         @user_manager.delete_user
      when "c"
         @user_manager.get_info
      when "d"
         @user_manager.list_all_users
      when "quit", "exit"
         bail
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
      if @user_manager.created_users.any?
         puts "Created Users:\n\n"
         @user_manager.created_users.each do |user|
            puts "#{user[:fname].capitalize} #{user[:lname].capitalize}\nUsername: #{user[:uname]}\n\n"
         end
         puts "-" * 80 + "\n"
      end
      # output users deleted in this session.
      if @user_manager.deleted_users.any?
         puts "Deleted Users:\n\n"
         @user_manager.deleted_users.each do |user|
            puts "#{user}\n\n"
         end
         puts "-" * 80 + "\n"
      end
      sleep 1
      exit!
   end

#############################################   

   
end

















