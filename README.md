hQuery
=========

The query composer is a web based application that provides the front end for creating, managing, and executing queries. 

Those queries are executed against the query gateway which exposes a query API, accepts queries, runs those queries against the patient data,
and returns the results of the query back to the query composer.

Environments
------------
hQuery will run properly on OSX and various distributions of Linux

hQuery will also run on Windows, however, there are some minor limitations to functionality and performance.

Dependencies
------------
* Ruby = 1.9.2
* Rails 3.1
* MongoDB >= 1.8.1

Install Instructions
--------------------

 Once you get a copy of the hQuery code from GitHub (http://github.com/hQuery), 
 these are step-by-step instructions to get hQuery installed on your local machine.
 
 These steps are the steps required to get both the Query Composer and Query Gateway up and running

###Summary of Steps OSX and LINUX
	1. Install Ruby
	2. Update Gems
	3. Install Git
	4. Install Mongo
	5. Create clone of repositories
	6. Populate Data
	7. Start Application
	8. Adding a User Account

###Summary of Steps for Windows
	1. (windows) Download and install Railsinstaller
	2. Update Gems
	3. Install Git (this step is not necessary if Railsinstaller used)
	4. Install Mongo
	5. (windows) Create Clone of repositories
	6. Populate Data
	7. (windows) Start Application
	8. Adding a User Account
	

###Common setup requirements for OSX and LINUX
	install ruby 1.9.2 or later
	install bundler 1.0.14 or later
	

###1.	 Ruby installation process for OSX and LINUX
	
	Ruby should be installed via RVM (Ruby Version Manager) when available. Details on rvm 
	can be found at https://rvm.beginrescueend.com/ including
	installation instructions.	The basic install procedure for RVM is as follows:
		 
		OSX
			First you will need to install XCode see: 
				http://developer.apple.com/technologies/tools/ 
			or install from your OSX install disk.

			open a terminal and run
				$ bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)
				$ rvm install 1.9.2
				$ rvm use 1.9.2

		LINUX
			 open a terminal and run
				 $ apt-get install ruby rubygems
				 $ apt-get install build-essential curl file zlib1g-dev libreadline5-dev libxml2-dev libsqlite3-dev
				 $ gem install rvm
				 $ /var/lib/gems/1.8/bin/rvm-install
				 $ rvm install 1.9.2
				 $ rvm use 1.9.2

###Getting Ruby Directly
	Ruby can also be installed directly from the following without the use of RVM.	

		http://www.ruby-lang.org/en/downloads/

		The rails installer may be helpful under windows.
 
###1w. WINDOWS - Download and install Railsinstaller
		
		a)	If you are working from behing a proxy, from the cmd prompt issue following command
		$ set HTTP_PROXY=http://proxy_host:proxy_port
		
		b) download and install railsinstaller
		
		http://railsinstaller.org/
	Packages included in version 1.1.1 are: 
		Ruby 1.8.7-p334
		Rails 3.0.7
		Git 1.7.3.1
		Sqlite 3.7.3
		TinyTDS 0.4.5
		SQL Server support 3.0.14
		DevKit
	Follow the included directions and these packages should be successfully installed.
	
		c) download rubyinstaller-1.9.2-p180 to update the version of ruby
				available: http://rubyinstaller.org/downloads/
			 1. install the ruby 1.9.2 installer
			 2. after install is complete open the windows control panel, and open system,
					then select the "Advanced" tab
			 3. click the environment variables button
			 4. under system variables, find PATH.	Click edit, and add C:\Ruby192\bin; 
					(make sure you have the trailing ';') to the BEGINNING of the path value
			 5. restart your command prompt and type ruby -v to verify the version reports 1.9.2p180
			 6. note, you will likely need to run set HTTP_PROXY=http://proxy_host:proxy_port 
					in the new prompt unless it's been set system wide, or you are not behind a proxy
		d) install the ruby dev kit, also avaialble at
				http://rubyinstaller.org/downloads/
			 The dev kit will allow building native gems.
			 1. near the bottom of the page you should see a link for the dev kit
				 DevKit-tdm-32-4.5.1-20101214-1400-sfx.exe
			 2. If you don't have MinGW installed, install it to c:/MinGW
					available: 
					http://sourceforge.net/projects/mingw/files/Automated%20MinGW%20Installer/mingw-get-inst/
					install all components when prompted
			 3. Running this exe will extract the contents.	 
					You should extract the contents to c:\DevKit
			 4. open a command prompt to the DevKit directory and run "ruby dk.rb init"
			 5. Veryify the new file config.yml contains a reference to Ruby192
			 6. run "ruby dk.rb install"
			 7.Next you will want to run pi.bat in the postinstall directory 

		 JRuby
			 currently jruby instructions are not available		 

###2.	 Gem Update

	 Bundler install process
		 Install ruby gems from:
			 http://rubygems.org/pages/download
				 1. download zip file
				 2. unzip zip file
				 3. in unzipped rubygems directory, run "ruby setup.rb"
	 
	 Bundler (http://gembundler.com/) is a Ruby Gem (http://en.wikipedia.org/wiki/RubyGems) 
	 that is used to manager the dependencies of a ruby application.	
	 
	 The bundler gem can be installed by running the following
	 command in the terminal once ruby has been installed.
	 
	 $	gem install bundler

###Getting the latest released version

	see: http://github.com/hquery/
	
	Getting the latest source code (skip to "Installing Mongo" if you are using the latest stable release)


###3.	 Installing GIT

	NOTE FOR WINDOWS:	 If you installed from the railsinstaller git will
	be installed so this step will not be needed

	In order to get access to the source code, you will require git.	
	If you do not already have git, it can be installed by following the directions at: 
	http://git-scm.com/download

###4.	 Installing MongoDB

	 The reference implementation uses a database called MongoDB (http://www.mongodb.org/).	 
	 In order to run the reference implementation, MongoDB must be installed.
	 MongoDB installers for most operating systems can be found at:
		 http://www.mongodb.org/downloads

###5.	 Getting the Code
	$ git clone http://githuburl/
	 
###5w. WINDOWS - Getting the Code 

 Register with Gitorious
 Request to be added to project

 From GitBash

 $ git clone <repository> <cloned repository name>

 for example:	 git clone ..................


###6.	 Populating example data
	 
	 Sample patient is added to the query gateway database in step 7
	 

###7.	 Starting the Application

	 In a terminal, change directory to the query-composer directory
	 run:
		 bundle install
		 bundle exec delayed_job start
		 bundle exec rails server

	 In a second terminal, change directory to the query-gateway directory
	 run:
		 bundle install
		 bundle exec rake db:seed
		 bundle exec delayed_job start
		 bundle exec rails server -p 3001
		 
In a browser open the URL: http://localhost:3000/queries/

###7w. WINDOWS - Starting the Application

verify gemfile has the following line:
gem "bson_ext", "~> 1.3", :platforms => :mri

verify bson_ext and mongo gems have same version.

	 In a terminal, change directory to the query-composer directory
	 run:
		 gem install bson_ext
		 bundle install
		 bundle exec ruby script/delayed_job run
		 bundle exec rails server

	 In a second terminal, change directory to the query-gateway directory
	 run:
		 bundle install
	 The gem nokogiri is set at version 1.4.4 but has an error on Windows.
	 To get around this, update to 1.4.4.1 and remove 1.4.4:
		 gem install nokogiri -v=1.4.4.1
	 gem uninstall nokogiri -v=1.4.4
	 
	 Finish starting the application by running:
		 bundle exec ruby script/delayed_job run
		 bundle exec rails server -p 3001
		 
	 In a browser open the URL: http://localhost:3000/queries/

###8. Adding a User Account

	When the application opens, you should be presented with a login page.
	You should see a sign up Link, click it.
	Fill out the form to create a user.
	Next you need to approve the user and set the user as an admin
	In the root of the query-composer project run the command:
		 bundle exec rake hquery:users:grant_admin USER_ID=<USERNAME>
	where <USERNAME> is replaced with the username for the user you just created.



License
-------

Copyright 2011 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Project Practices
-----------------

Please try to follow our [Coding Style Guides](http://github.com/eedrummer/styleguide). Additionally, we will be using git in a pattern similar to [Vincent Driessen's workflow](http://nvie.com/posts/a-successful-git-branching-model/). While feature branches are encouraged, they are not required to work on the project.