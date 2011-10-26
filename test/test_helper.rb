require 'cover_me'
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'fakeweb'
require 'factory_girl'
require 'mocha'
require 'pry'

FactoryGirl.find_definitions

class ActiveSupport::TestCase

  def dump_database
    Mongoid::Config.master.collections.each do |collection|
      collection.drop unless collection.name.include?('system.')
    end
    Mongoid::Config.master['system.js'].remove({})
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
