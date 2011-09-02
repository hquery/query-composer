require 'cover_me'
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'fakeweb'
require 'factory_girl'
require 'mocha'
require 'pry'
require 'ruby-debug'

FactoryGirl.find_definitions

class ActiveSupport::TestCase

  def dump_database
    User.all.each {|x| x.destroy}
    BaseQuery.all.each {|x| x.destroy}
    Endpoint.all.each {|x| x.destroy}
    EndpointLog.all.each {|x| x.destroy}
    LibraryFunction.all.each {|x| x.destroy}
    Result.all.each {|x| x.destroy}
    db = Mongoid::Config.master
    db['system.js'].remove({})
  end

  def dump_jobs
    Delayed::Job.destroy_all
  end
  
  def assert_lists_equal(expected, actual) 
    assert_equal expected.length, actual.length
    expected.each do |item|
      assert actual.include?(item)
    end
  end

end
