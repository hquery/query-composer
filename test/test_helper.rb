require 'cover_me'
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'fakeweb'

class ActiveSupport::TestCase
  def collection_fixtures(collection)
    MONGO_DB[collection].drop
    ids = []
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
      #puts "Loading #{json_fixture_file}"
      fixture_json = JSON.parse(File.read(json_fixture_file))
      query = Query.new(fixture_json)
      query.endpoints.each {|endpoint| endpoint.identify}
      query.save!
      ids << query.id
    end
    ids
  end
end
