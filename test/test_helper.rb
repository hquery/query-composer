require 'cover_me'
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'fakeweb'
require 'factory_girl'

Factory.find_definitions

class ActiveSupport::TestCase

  def dump_database
    User.all.each {|x| x.destroy}
    Query.all.each {|x| x.destroy}
    Endpoint.all.each {|x| x.destroy}
    Event.all.each {|x| x.destroy}
  end

  def dump_jobs
    Delayed::Job.destroy_all
  end

end
