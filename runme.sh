#!/bin/sh
# Toggle the USE_SSL_SERVER and USE_SSL_CLEINT variables in config/ssl_config.rb to enable/disable SSL support.
# The variable USE_SSL_SERVER configures encrypted browser access to the query-composer.
# The variable USE_SSL_CLIENT configures whether traffic between composer and gateway is SSL encrypted.  If it is
# being tunnelled through ssh, then is isn't necessary to also SSL encrypt it.

echo "Installing Dependencies"
bundle install
echo "Starting Delayed Job"
bundle exec script/delayed_job start
echo "Starting Composer"
bundle exec rails server -p 3002
echo "Stopping Delayed Job"
bundle exec script/delayed_job stop

# To start query-gateway
# In a second terminal, change directory to the query-gateway directory
# and run:
#
#    bundle install
#    bundle exec rake db:seed
#    bundle exec script/delayed_job start
#    bundle exec rails server -p 3001
#     
#In a browser open the URL: https://localhost:3000/queries/
#
# Adding a User Account (one time operation)
#
# When the web application opens, you should be presented with a login page.
# You should see a sign up Link, click it.
# Fill out the form to create a user.
# Next you need to approve the user and set the user as an admin
# In the root of the query-composer project run the command:
##  
#    bundle exec rake hquery:users:grant_admin USER_ID=<USERNAME>
#  
# where <USERNAME> is replaced with the username for the user you just created.
