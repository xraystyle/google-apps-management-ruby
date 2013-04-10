#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class Controller

   attr_accessor :session, :username, :user_manager, :group_manager

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
      @user_setup = UserSetup.new
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
      system("clear")
      puts "\n\n"
      puts "GApps User Provisioning".center(100)
      if subsection
         puts "\n"
         puts "#{subsection}".center(100)
      end
      puts "\n\n"
      puts "*" * 100
      puts "\n\n"
   end

   #Get user input to perform actions
   def prompt

      $stdout.sync = true
      options = ["a","b","c","quit","exit"]
      print_header
      puts "Options:\n"
      puts "A. User Management"
      puts "B. Group Management"
      puts "C. Complete User Setup"
      puts
      puts "To exit, type \"quit\", or \"exit\""
      print "> " 
      response = gets.chomp.downcase.strip
      
      while !options.include?(response)
         puts 'Try again. ("A"", "B", "C" or "quit")'
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
      when "c"
         system("clear")
         @user_setup.rockandroll!
      when "quit", "exit"
         bail
      end
   end
   
   # gtfo
   def bail
      system("clear")
      puts "\n\n"
      puts "Thanks for using GApps User Provisioning!".center(100)
      puts "\n\n"
      puts "*" * 100
      puts "\n\n"

      # output users and groups created in this session.

      if @user_manager.created_users.any?
         puts "Created Users:\n\n"
         @user_manager.created_users.each do |user|
            puts "#{user[:fname].capitalize} #{user[:lname].capitalize}\nUsername: #{user[:uname]}\n\n"
         end
         puts "-" * 100 + "\n"
      end
      
      if @group_manager.created_groups.any?
         puts "Created Groups:\n\n"
         @group_manager.created_groups.each do |group_id|
            puts "#{group_id}\n\n"
         end
         puts "-" * 100 + "\n"
      end
      
      # output users and groups deleted in this session.
      if @user_manager.deleted_users.any?
         puts "Deleted Users:\n\n"
         @user_manager.deleted_users.each do |user|
            puts "#{user}\n\n"
         end
         puts "-" * 100 + "\n"
      end

      if @group_manager.deleted_groups.any?
         puts "Deleted Groups:\n\n"
         @group_manager.deleted_groups.each do |group_id|
            puts "#{group_id}\n\n"
         end
         puts "-" * 100 + "\n"
      end

      sleep 1
      exit!
   end

   def check_timeout
      
      unless @session
         re_auth(@username)        
      end
      
   end

#############################################   

   
end

















