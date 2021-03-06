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
		puts "e.g. \"f.last, first.last, otherusername, etc.\"\n"
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
		puts "A new user will be created with the following information:\n"
		puts

		puts "First and last name:" 
		puts "#{@userdata[:fname]} #{@userdata[:lname]}\n\n".bold

		puts "Username:"
		puts "#{@userdata[:uname]}".bold
		puts

		print "Email aliases: \n"
		
		@alias_list.each do |e|
			puts "#{e} ".bold
		end
		puts

		puts
		print "The new user will be added to the following groups: \n"

		@group_numbers.each do |number|
			puts "#{@all_groups[number.to_i - 1]} ".bold
		end
		puts
		puts

		
	end

	def rockandroll!
		@all_groups = @controller.group_manager.refresh_groups
		basic_user_data
		get_aliases
		get_groups
		confirm_data

		puts
		puts "Is this information correct? Enter \"y\" to proceed with user creation, \"n\" to cancel \nand return to the main menu."
		puts
		print "> "
		response = gets.chomp.strip.downcase
		system "clear"


		case response
		when "y","yes"
			# make the user, add aliases to user, add user to groups.
			@controller.check_timeout
		    begin
		        # Create the user account
		        @controller.session.create_user(@userdata[:uname], @userdata[:fname], @userdata[:lname], @userdata[:default_pass])
		        @controller.user_manager.created_users << @userdata
		        puts "User created, setting up email aliases...".green
		        sleep 3
		        # Set up aliases
		        @alias_list.each do |a|
		        	@controller.session.create_nickname(@userdata[:uname],a)
		        end
		        puts "Done, adding user to groups...".green
		        sleep 3

		        # Add user to groups
		        @group_numbers.each do |number|
		        	@controller.session.add_member_to_group(@userdata[:uname],@all_groups[number.to_i - 1])
		        end

		    rescue GDataError => e
		        puts "Uh oh, something went wrong.".red + " Check if the user was created, then try again."
		        puts "errorcode = " + e.code, "input : " + e.input, "reason : " + e.reason
		        puts "Press enter to continue..."
		        gets
		        @controller.prompt
		    end
		when "n","no"
			# pop smoke and break contact. Back to main menu.
			puts "User setup cancelled."
			sleep 2
			@controller.prompt
		end

		# report successfull creation of user
		puts "User creation successful!\n\n".green
		sleep 2
		@controller.user_manager.get_info(@userdata[:uname])
		puts "Press enter to continue..."
		gets
		@controller.prompt
		# puts "\nUser created successfully:\n"
	 	#puts "#{user_data[:fname].titleize} #{user_data[:lname].titleize}\nUsername: #{user_data[:uname]}\n"
	 	#puts "Press enter to continue..."
	 	#gets
	 	#system("clear")
	 	#user_prompt
	end





end





















