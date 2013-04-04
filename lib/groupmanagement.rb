#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class GroupManagement

	def initialize
		@controller = Controller.current_controller
        @created_groups = []
        @deleted_groups =[]
	end


    def group_prompt

        $stdout.sync = true
        options = ["a","b","c","d","menu","exit","quit"]
        system "clear"
        @controller.print_header("Group Management")
        puts "Options:\n"
        puts "A. Create a group."
        puts "B. "
        puts "C. "
        puts "D. List all groups."
        puts
        puts "To go back to the main menu, type \"Menu\""
        puts "To exit, type \"quit\", or \"exit\""
        print "> "
        response = gets.chomp.downcase.strip
      
        while !options.include?(response)
            puts 'Try again. ("A"", "B", "C", "D" or "Menu")'
            print "> "
            response = gets.chomp.downcase.strip
        end

        group_action(response)                      

    end


    def action_header(action)

        system("clear")
        puts "\n\n#{action}\n\n"
        puts "*" * 100
        puts "\n\n"
        
    end


    def group_action(action)
        case action
        when "a"
           create_group
        # when "b"
        #    delete_user
        # when "c"
        #    get_info
        when "d"
           list_all_groups
        when "menu"
            system 'clear'
            @controller.prompt
        when "quit", "exit"
            @controller.bail
        end
    end


    def list_all_groups
        @controller.check_timeout
        system("clear")
    	group_list = @controller.session.retrieve_all_groups
        num = 1
        line_toggler = 0
        puts "*" * 100
        puts "\nGroups in this domain:\n\n"
        if group_list == []
            puts "There are currently no groups in this domain."
        else
            group_list.each do |group|
                case line_toggler.even?
                when true
                    print "#{num}. #{group.group_id}".ljust(40)
                    num += 1
                    line_toggler += 1
                when false
                    puts "#{num}. #{group.group_id}".ljust(40)
                    num += 1
                    line_toggler += 1
                end
            end
        end
        puts
        puts "*" * 100
        puts
        puts "Press enter to continue..."
    	gets
    	group_prompt

    end



    def create_group

        @controller.check_timeout
        # create a group
        # usage: @controller.session.create_group(group_id, properties)
        group_data = {}
        action_header("Create A Group")

        # Build the group data.
        puts "Choose an email address for the group. The domain must be managed by this Google Apps account."
        puts "Example: \"group@my-domain.com\""
        print "Enter the email address of the new group: "
        group_id = gets.chomp.strip.downcase
        print "Enter a name for the group: "
        group_data[:group_name] = gets.chomp.strip
        print "Enter a short description for the group: "
        group_data[:group_desc] = gets.chomp.strip
        puts
        puts "Who should be able to post to this group?"
        puts "A. Owners of the group only."
        puts "B. Members of the group only."
        puts "C. Any user who belongs to the same domain as the group."
        puts "D. Anyone."
        print "> "
        response = gets.chomp.strip.downcase
        options = ["a","b","c","d"]
        # check for valid input.
        while !options.include?(response)
            puts 'Try again. ("A", "B", "C", or "D")'
            response = gets.chomp.strip.downcase
        end
        sleep 1
        case response
        when "a"
            group_data[:email_priv] = "Owner"
        when "b"
            group_data[:email_priv] = "Member"
        when "c"
            group_data[:email_priv] = "Domain"
        when "d"
            group_data[:email_priv] = "Anyone"
        end


        # Idiot-check data with the user.
        action_header("Create A Group")

        puts "A new group will be created with the information below:\n\n"
        puts "Group ID: #{group_id}\n"
        puts "Group Name: #{group_data[:group_name]}\n"
        puts "Group Description:\n#{group_data[:group_desc]}\n"
        print "Who can post to this group: "
        
        case group_data[:email_priv]
        when "Owner"
            puts "Group Owners Only"
        when "Member"
            puts "Group Members Only"
        when "Domain"
            puts "All Members Of This Domain"
        when "Anyone"
            puts "Anyone"
        end

        puts "\nIs this information correct? Enter \"yes\" to create the group, or \"no\" to cancel."
        response = gets.chomp.strip.downcase

        options = ["y","yes","n","no"]
        while !options.include?(response)
            puts 'Try again, "yes" to create, "no" to cancel.'
            response = gets.chomp.strip.downcase
        end

        case response
        when "n", "no"
            puts "Group creation cancelled."
            sleep 3
            group_prompt            
        when "y", "yes"
            begin
                @controller.session.create_group(group_id, group_data.values)
            rescue GDataError => e
                puts "Group creation failed."
                puts "Reason: #{e.reason}"
                group_prompt
            end
            puts "Group created successfully."
            sleep 3
            group_prompt
        end
        
    end






    def update_group
        
        # update group attributes
        # usage: @controller.session.update_group(group_id, properties)

    end

    def delete_group
        
        # delete group
        # usage: @controller.session.delete_group(group_id)

    end

    
    def add_member_to_group

        # add member to a group
        # usage: @controller.session.add_member_to_group(email_address, group_id)
        
    end


    def remove_member_from_group

        # usage: @controller.session.remove_member_from_group(email_address, group_id)
        
    end









end





































