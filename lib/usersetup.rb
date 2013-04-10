#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class UserSetup

	def initialize

		@controller = Controller.current_controller

		
	end

	def basic_user_data

		@controller.print_header("Complete User Setup")
		@userdata = @controller.user_manager.create_user(true)
		
	end

	def get_aliases

		@controller.print_header("Complete User Setup")
		puts "\nEnter any email aliases for this user, separated by commas."		
		puts "e.g. \"f.last@example.com, first.last@example.com, otherusername@example.com, etc.\"\n"
		print "> "
        aliases = gets.chomp.strip.downcase
        @alias_list = aliases.gsub(" ","").split(",")
        sleep 1
		
	end

	def get_groups

		@controller.print_header("Complete User Setup")
		puts "Select the groups you would like to add the new user to."
		puts "A numbered list of groups will be displayed below."
		puts "Press enter to continue..."
		gets
		@controller.group_manager.list_all_groups(true)
		puts "Enter the numbers of the groups you would like to add the new user to."
		puts "e.g. \"1, 3, 14, 7\""
		print "> "
		groups = gets.chomp.strip.downcase
		@group_numbers = groups.gsub(" ","").split(",")
		sleep 2
		
	end

	def confirm_data

		@controller.print_header("Complete User Setup")
		puts "A new user will be created with the following information:"

		puts "First and last name: #{@userdata[:fname]} #{@userdata[:lname]}\n"
		print "Email aliases: "
		
		@alias_list.each do |e|
			print "#{e}, "
		end

		puts
		print "The new user will be added to the following groups: "

		@group_numbers.each do |number|
			print "#{@all_groups[number - 1]}, "
		end

		
	end

	def rockandroll!

		@all_groups = @controller.group_manager.refresh_groups
		basic_user_data
		get_aliases
		get_groups
		confirm_data

		puts
		puts "Is this information correct? Enter \"y\" to proceed with user creation, \"n\" to cancel \nand return to the main menu."
		response = gets.chomp.strip.downcase

		case response
		when "y","yes"
			# make the user, add aliases to user, add user to groups.
		when "n","no"
			# pop smoke and break contact. Back to main menu.
		end

		# report successfull creation of user
		# press enter to continue, then back to main menu.			


	end





end





















