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
  
  def setup_users() 
    MONGO_DB['users'].drop
    @user = Factory(:user)
    ids = []
    ids.push @user.id
  end
end
