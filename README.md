Google Apps User Provisioning Tool
---------------------------------------

This is a ruby app that acts as a CLI for your Google Apps domain.

The app uses the Google Apps provisioning API Ruby client found here: http://code.google.com/p/gdatav2rubyclientlib/

This app also makes use of the Highline gem for more advanced control over user input. 
More info on that here: http://highline.rubyforge.org/

Currently the app can list user info given a username, and add and delete users from the domain. The app can also list all the users in the domain, either just by username, or by full user info.

The plan is that this app will eventually be able to send welcome emails to newly added users and be able to manage group membership as well.

WHAT YOU NEED TO MAKE THIS WORK:
-----------------------------------

1.	A Mac or Linux box. Code is untested on Linux, but I see no reason why it shouldn't work. (Probably won't 	  work on Windows, and I'm never gonna try to make it work on Windows.)

2. 	The Ruby 'Highline' gem. `$: gem install highline`

You may need to dial in your environment somewhat to make this work properly. I've got this working with RVM using Ruby 2.0.0 on OS X 10.8.2.

The main tweak I had to make was to install the curl-ca-bundle via Macports (`sudo port install curl-ca-bundle`), then point Net::HTTPS at the path to the cert store. It's in gappsprovisioning/connection.rb on line 33. If you're using a different cert store you'll have to update the path there. If you feel like monkeying with environment variables you can take a look here: http://mentalized.net/journal/2012/08/10/ssl_certificate_woes_with_ruby_19_and_os_x/

CHANGELOG
------------

3/25/13: I've started on the group management. It's not working yet. 
