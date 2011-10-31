source :rubygems

gem 'rails'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'
gem 'sprockets'
gem 'bson_ext', :platforms => :mri
gem "mongoid"
gem 'mongoid_rails_migrations'
gem 'simple_form'
gem 'multipart-post'
gem 'delayed_job'
#gem 'delayed_job_mongoid', :git => 'https://github.com/cyrilpic/delayed_job_mongoid.git', :branch => 'nil_error'
gem 'delayed_job_mongoid', :git => 'https://github.com/collectiveidea/delayed_job_mongoid.git'
gem 'hquery-patient-api', :git=>'http://github.com/hquery/patientapi.git', :branch=> 'develop'
#gem 'hquery-patient-api', :git=>'http://github.com/hquery/patientapi.git', :tag=> 'V0.1'
gem 'devise'
gem 'cancan'
gem 'pry'
gem 'kramdown'
gem 'jasmine', :group => [:development, :test]
#gem 'jasmine',
#  :git        => 'https://github.com/hjdivad/jasmine-gem.git',
#  :submodules => true,
#  :branch     => 'jscoverage'
gem 'headless', :group => [:development, :test]
gem 'coderay'



# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'cover_me', '>= 1.0.0.rc6'
  gem 'minitest'
  gem 'fakeweb'
  gem 'therubyracer', :platforms => :ruby
  gem 'therubyrhino', :platforms => :jruby
  gem 'factory_girl'
  gem 'mocha', :require => false
end
