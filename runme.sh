#!/bin/sh
# To start query-composer
bundle install
bundle exec script/delayed_job start
bundle exec rails server -p 3002
#
# To start query-gateway
# In a second terminal, change directory to the query-gateway directory
# and run:
#
#    bundle install
#    bundle exec rake db:seed
#    bundle exec script/delayed_job start
#    bundle exec rails server -p 3001
#     
#In a browser open the URL: http://localhost:3000/queries/
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
