source 'https://rubygems.org'

gem 'rails', '=3.2.13'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'daemons'
gem 'jquery-rails', '=1.0.19'
gem 'sprockets'
gem 'webrick', '1.3.1'

gem 'mongoid'
gem 'mongoid_rails_migrations'

gem 'simple_form'

gem 'multipart-post'
gem 'delayed_job'
gem 'delayed_job_mongoid'

gem 'hquery-patient-api', :git => 'https://github.com/scoophealth/patientapi.git', :branch => 'master'

gem 'coderay'

gem 'devise'
gem 'cancan'
gem 'pry'
gem 'kramdown'
gem 'jasmine', :group => [:development, :test]
gem 'headless', :group => [:development, :test]

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'minitest', '< 5.0.0'
  gem 'turn', :require => false
  gem 'cover_me', '>= 1.0.0.rc6', :platforms => :ruby
  gem 'factory_girl'
  gem 'fakeweb'
  gem 'mocha', :require => false
  gem 'therubyracer', :platforms => :ruby
  gem 'therubyrhino', :platforms => :jruby
end
