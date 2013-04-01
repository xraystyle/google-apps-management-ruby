#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class Controller

   attr_accessor :session, :username

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
      @user_manager = UserManagement.new
      @group_manager = GroupManagement.new
   end
   
   def re_auth(username)
      puts
      puts "Session timed out, please re-authenticate."
      @auth = LogIn.new(@@current_controller.username)
      @session = @auth.gapps_session
   end

   def run!
      # Start doing shit.
      prompt      
   end

   def print_header(subsection=nil)
      puts "\n\n"
      puts "GApps User Provisioning".center(80)
      if subsection
         puts "\n"
         puts "#{subsection}".center(80)
      end
      puts "\n\n"
      puts "*" * 80
      puts "\n\n"
   end

   #Get user input to perform actions
   def prompt

      $stdout.sync = true
      options = ["a","b","quit","exit"]
      print_header
      puts "Options:\n"
      puts "A. User Management"
      puts "B. Group Management"
      puts "To exit, type \"quit\", or \"exit\""
      print "> " 
      response = gets.chomp.downcase.strip
      
      while !options.include?(response)
         puts 'Try again. ("A"", "B", or "quit")'
         print "> "
         response = gets.chomp.downcase.strip
      end
      
      do_action(response)                      
   end
   
   # Get the action returned from 'prompt'. Clean up the input and pass to appropriate method.
   def do_action(action)
      case action
      when "a"
         @user_manager.user_prompt
      when "b"
         @group_manager.group_prompt
      when "quit", "exit"
         bail
      end
   end
   
   # gtfo
   def bail
      system("clear")
      puts "\n\n"
      puts "Thanks for using GApps User Provisioning!".center(80)
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

   def timed_out?
      
      if @session
         false
      else
         true
      end
      
   end

#############################################   

   
end

















