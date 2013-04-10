#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class GroupManagement

    attr_accessor :created_groups, :deleted_groups

	def initialize
		@controller = Controller.current_controller
        @created_groups = []
        @deleted_groups =[]
        @group_ids =[]
        refresh_groups
    end


    def refresh_groups
        @group_list = @controller.session.retrieve_all_groups
        @group_list.each { |group| @group_ids << group.group_id  }
        return @group_ids  
    end



    def group_prompt

        $stdout.sync = true
        options = ["a","b","c","d","e","f","menu","exit","quit"]
        system "clear"
        @controller.print_header("Group Management")
        puts "Options:\n"
        puts "A. Create a group."
        puts "B. Delete a group."
        puts "C. Add users to a group."
        puts "D. Remove users from a group."
        puts "E. Get info about a group."
        puts "F. List all groups."
        puts
        puts "To go back to the main menu, type \"Menu\""
        puts "To exit, type \"quit\", or \"exit\""
        print "> "
        response = gets.chomp.downcase.strip
      
        while !options.include?(response)
            puts 'Try again. ("A"", "B", "C", "D", "E", "F" or "Menu")'
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
        when "b"
           delete_group
        when "c"
           add_member_to_group
        when "d"
           remove_member_from_group
        when "e"
            get_info
        when "f"
            list_all_groups
        when "menu"
            system 'clear'
            @controller.prompt
        when "quit", "exit"
            @controller.bail
        end
    end


    def list_all_groups(usersetup?=false)

        @controller.check_timeout
        system("clear")
        num = 1
        line_toggler = 0
        puts "*" * 100
        puts "\nGroups in this domain:\n\n"
        if @group_list == []
            puts "There are currently no groups in this domain."
        else
            @group_list.each do |group|
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

        unless usersetup?
           
            puts "Press enter to continue..."
            gets
            group_prompt
                    
        end


    end



    def create_group

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
        print "> "
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
                @controller.check_timeout
                @controller.session.create_group(group_id, group_data.values)
                @created_groups << group_id
                refresh_groups
            rescue GDataError => e
                puts "Group creation failed."
                puts "Reason: #{e.reason}"
                group_prompt
            end
            puts "Group created successfully."
            puts "Press \"enter\" to continue..."
            group_prompt
        end
        
    end




    def update_group
        
        # I don't think I've ever needed to modify a group. I'm
        # not going to implement this method at this time because 
        # I'd likely never use it.
        # --xraystyle

        # update group attributes
        # usage: @controller.session.update_group(group_id, properties)


    end

    def delete_group
        

        # delete group
        # usage: @controller.session.delete_group(group_id)
        action_header("Delete A Group")
        print "Enter the email address of the group you'd like to delete: "
        response = gets.chomp.strip.downcase

        if @group_ids.include?(response)
            begin
                @controller.check_timeout
                @controller.session.delete_group(response)
                @deleted_groups << response
                refresh_groups
            rescue GDataError => e
                puts "Group deletion failed."
                puts "Reason: #{e.reason}"
            end
        else
            puts "Group \"#{response}\" not found. Try again."
            sleep 2
            group_prompt
        end

        puts "Group \"#{response}\" deleted successfully."
        puts "Press \"enter\" to continue..."
        gets
        group_prompt

    end

    
    def add_member_to_group(userID=nil,groupID=nil)

        # quick add when passed vars from elsewhere.
        if userID && groupID
            @controller.check_timeout
            @controller.session.add_member_to_group(userID, groupID)
        end

        # add member to a group
        # usage: @controller.session.add_member_to_group(email_address, group_id)
        action_header("Add User To A Group")
        print "Enter the name of the group you'd like to add users to: "
        the_group = gets.chomp.strip.downcase
        puts "Enter the names of the users you'd like to add to the group, separated by commas."
        puts "Ex: \"maude, jeff, walter, donny\""
        print "> "
        userlist = gets.chomp.strip.downcase
        the_users = userlist.gsub(" ","").split(",")
        sleep 1

        action_header("Add User To A Group")
        puts "The following users will be added to \"#{the_group}\"."
        
        the_users.each do |user| 
            puts "\"#{user}\""
        end

        puts
        puts "Is this correct?(y/n)"
        print "> "
        y_n = gets.chomp.strip.downcase

        case y_n
        when "y", "yes"
            @controller.check_timeout
            begin
                the_users.each do |user|
                    @controller.session.add_member_to_group(user, the_group)
                end
            rescue GDataError => e
                puts "Adding user to group failed."
                puts "Reason: #{e.reason}. Please try again."
                sleep 3
                group_prompt
            end

        when "n", "no"
            puts "Group addition cancelled."
            sleep 3
            group_prompt
        end

        action_header("Add User To A Group")
        puts "The following users were successfully added to \"#{the_group}\"."

        the_users.each do |user| 
            puts "\"#{user}\""
        end

        print "Press \"enter\" to continue..."
        gets
        group_prompt        
    end


    def remove_member_from_group

        # usage: @controller.session.remove_member_from_group(email_address, group_id)
        action_header("Remove User From A Group")
        print "Enter the name of the group you'd like to remove users from: "
        the_group = gets.chomp.strip.downcase
        puts "Enter the names of the users you'd like to remove, separated by commas."
        puts "Ex: \"maude, jeff, walter, donny\""
        print "> "
        userlist = gets.chomp.strip.downcase
        the_users = userlist.gsub(" ","").split(",")
        sleep 1

        action_header("Remove User From A Group")
        puts "The following users will be removed from \"#{the_group}\"."
        
        the_users.each do |user| 
            puts "\"#{user}\""
        end

        puts "Is this correct?(y/n)"
        print "> "
        y_n = gets.chomp.strip.downcase

        case y_n
        when "y", "yes"
            @controller.check_timeout
            begin
                the_users.each do |user|
                    @controller.session.remove_member_from_group(user, the_group)
                end
            rescue GDataError => e
                puts "Removing user from group failed."
                puts "Reason: #{e.reason}. Please try again."
                sleep 3
                group_prompt
            end

        when "n", "no"
            puts "Group modification cancelled."
            sleep 3
            group_prompt
        end

        puts "The following users were successfully removed from \"#{the_group}\"."

        the_users.each do |user| 
            puts "\"#{user}\""
        end

        print "Press \"enter\" to continue..."
        gets
        group_prompt

    end

    def get_info

        # usage: @controller.session.retrieve_all_members(group_id)
        action_header("Get Group Info")
        print "Enter the name of the group you'd like info about: "
        the_group = gets.chomp.strip.downcase

        begin
            @controller.check_timeout
            memberlist = @controller.session.retrieve_all_members(the_group)
            ownerlist = @controller.session.retrieve_all_owners(the_group)
        rescue GDataError => e
            puts "Group info retrieval failed."
            puts "Reason: #{e.reason}"
            puts "Press enter to continue..."
            gets
            group_prompt
        end

        action_header("Get Group Info")
        puts "Info for #{the_group}"
        puts 
        puts "Users in this group:"

        if memberlist.any?
            memberlist.each do |member| 
                puts "\"#{member.member_id}\""
            end
        else 
            puts "There are currently no users in this group.\n"
        end

        puts
        puts "Group Owners:"

        if ownerlist.any?
            ownerlist.each do |owner|
                puts "\"#{owner.owner_id}\""
            end
        else
            puts "This group currently has no owners.\n\n"
        end

        puts "Press enter to continue..."

        gets
        group_prompt

    end








end




































