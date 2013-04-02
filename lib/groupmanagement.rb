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
        puts "A. List All Groups"
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
           list_all_groups
        # when "b"
        #    delete_user
        # when "c"
        #    get_info
        # when "d"
        #    list_all_users
        when "menu"
            system 'clear'
            @controller.prompt
        when "quit", "exit"
            @controller.bail
        end
    end


    def list_all_groups
        if @controller.timed_out?
            @controller.re_auth(@controller.username)
            list_all_groups
        else

        	group_list = @controller.session.retrieve_all_groups
            num = 1
            line_toggler = 0
            puts "*" * 80
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
            puts "*" * 80
            puts
            puts "Press enter to continue..."
        	gets
        	group_prompt
        end

    end


end





































