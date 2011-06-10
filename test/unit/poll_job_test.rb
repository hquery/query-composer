require 'test_helper'

class VendorTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('queries')
  end

  test "Aggregation" do
    queries = Query.all.to_a
    assert queries.size==1
    query = queries[0]
    PollJob.aggregate query
    assert query.aggregate_result != nil
    assert query.aggregate_result['count'] == 20
  end

end