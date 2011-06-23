require 'cover_me'
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'fakeweb'
require 'factory_girl'

Factory.find_definitions

class ActiveSupport::TestCase

  def collection_fixtures(collection, user, should_clear=true)
    MONGO_DB[collection].drop if should_clear
    ids = []
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
      fixture_json = JSON.parse(File.read(json_fixture_file))
      query = Query.new(fixture_json)
      query.endpoints.each {|endpoint| endpoint.identify}
      query.user = user
      query.save!
      ids << query.id
    end
    ids
  end
  
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
