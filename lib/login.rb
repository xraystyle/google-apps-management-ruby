#!/usr/bin/ruby

# xraystyle's GApps User Provisioning Tool 
# https://github.com/xraystyle/google-apps-management-ruby

class LogIn
   
   attr_accessor :username, :gapps_session

   
   def initialize(user=nil)
      ask_for_creds(user)
      begin
         @gapps_session = ProvisioningApi.new(@username, @password)
         # Set password to nil as soon as we're done with it.
         @password = nil
      rescue 
         puts
         print "Log-in failed.".red + " Likely incorrect username or password.\nRetry? (y/n): "
         response = gets.chomp.downcase.strip
         
         case response
         when "y", "yes"
            @gapps_session = nil
            @username = nil
            user = nil
            @password = nil
            initialize
         when "no", "n"
            puts "Check your login credentials, then try again."
            exit!
         end
         
      end
      start_timeout  
   end
   
   #### Ask For Credentials ####
   # ask_for_creds requests the user's email address for
   # their GApps domain and their password. Password input
   # is supressed via STDIN.noecho.
   
   def ask_for_creds(user=nil)
      if user
         @username = user
      else
         print "Enter your GApps email address: "
         @username = gets.chomp.strip.downcase         
      end

      print "Enter your password:  "
      @password = STDIN.noecho(&:gets)
   end
    
      #### Start Timeout ####


   # start_timeout spins off a new thread that sleeps
   # for 5 minutes, then sets the user's authenticated session
   # back to nil. This prevents the user's Google Apps session from being
   # stored indefinetly while the app is running.

   def start_timeout
          timeout=Thread.new {
             sleep 300
             @gapps_session = nil
             Controller.current_controller.session = nil
             }
   end

end