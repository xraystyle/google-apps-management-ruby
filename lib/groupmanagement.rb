#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class GroupManagement

	def initialize
		@controller = Controller.current_controller
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


    def group_action(action)
        case action
        when "a"
           
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
    	group_list = @controller.session.retrieve_all_groups
        num = 1
        line_toggler = 0
        puts "*" * 100
        puts "\nGroups in this domain:\n\n"

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
        
        system("clear")
        puts "\n\nCreate A User\n\n"
        puts "*" * 100
        puts "\n\n"
        
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





































