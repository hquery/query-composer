source 'http://rubygems.org'

gem 'rails', '3.1.0.rc5'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "~> 3.1.0.rc"
  gem 'coffee-rails', "~> 3.1.0.rc"
  gem 'uglifier'
end

gem 'jquery-rails'
gem 'sprockets', '= 2.0.0.beta.13' 
gem 'bson_ext', :platforms => :mri
gem "mongoid", "~> 2.0"
gem 'mongoid_rails_migrations'
gem 'simple_form'
gem 'multipart-post'
gem 'delayed_job'
gem 'delayed_job_mongoid'
gem 'hquery-patient-api', :git=>'http://github.com/hquery/patientapi.git', :branch=> 'develop'
gem 'devise'
gem 'cancan'
gem 'pry'
#gem 'ruby-debug19'
gem 'bluecloth'
gem 'jasmine', :group => [:development, :test]
gem 'headless', :group => [:development, :test]

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'cover_me', '>= 1.0.0.rc6'
  gem 'fakeweb'
 # gem 'therubyracer'
  gem 'factory_girl'
  gem 'mocha', :require => false
end
