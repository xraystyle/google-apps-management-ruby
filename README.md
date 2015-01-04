Google Apps User Provisioning Tool
---------------------------------------

This is a ruby app that acts as a CLI for your Google Apps domain.

The app uses the Google Apps provisioning API Ruby client found here: http://code.google.com/p/gdatav2rubyclientlib/

Currently the app can manage user accounts and groups within the domains in your Google Apps account. The app can also
create a user, set up aliases and add the new user to groups in one workflow.


USAGE NOTES:
-------------

1.	Tested working on a Mac, using Ruby 1.8.7, 2.0.0, 2.1.4 and 2.2.0 installed via RVM. Code is untested on Linux, but I see no reason why it shouldn't work. I've never tested it on Windows and I don't plan to. Let me know if you do.

2.	~~You'll need the Ruby 'Highline' gem. `$: gem install highline`~~ Rubygems dependencies have been removed, the app should run as-is without any gems installed!

3.	I also had to install the curl-ca-bundle in order for SSL to function. Additionally, I had to point the app at the path to the cert store for it to be recognized. I installed the bundle via Homebrew (`brew install curl-ca-bundle`), but you can grab it via Macports or manually, I'm sure. Once installed, make sure line 33 of gappsprovisioning/connection.rb points to the correct path to the cert store. It's currently set for the default install path using Homebrew. If you'd like to try to get it up and running by tweaking environment variables, have a look at this link: http://mentalized.net/journal/2012/08/10/ssl_certificate_woes_with_ruby_19_and_os_x/

4.	When creating a user account, the user is assigned a default password. This password is set on line 68 of lib/usermanagement.rb. You can set it to whatever you'd like.



CHANGELOG
------------

01/03/15: Refactoring, Bugfixes, Output Formatting
Refactored the app to get rid of dependencies on Rubygems and the 'Highline' gem. App will now run on a system without Rubygems or the highline gem installed!

Text output is now better formatted and colorized! Success messages are green, errors are red, etc.

Fixed several bugs where the user would receive no feedback when errors were encountered.

Removed/refactored some redundant code, added comments and removed a lot of old, commented-out debugging code.

09/19/14: Bugfixes
The full list of groups wasn't reflecting changes made if groups were added or deleted during the session. Changed text output on user and group deletion methods so that they're consistent in both places.

04/10/13: Complete User Setup has been implemented!  
The main menu now has an option for Complete User Setup. This option allows you to create a new user account, add email aliases to it and add the user to any groups in the domain in a single workflow. Last to do is set up sending of welcome
emails to the new user. Maybe later in the week.

04/08/13: I CAN HAS COMMITS! Group management is up and working. App has the ability to list groups, get group info, create and delete groups as well as add and remove users. All functionality is 
tested working but could probably use some more cleanup/error-checking here and there.


03/25/13: I've started on the group management. It's not working yet. 
