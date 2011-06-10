require 'test_helper'

class VendorTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('queries')
  end

  test "Aggregation" do
    queries = Query.all.to_a
    assert queries.size==3
    queries.each do |query|
      PollJob.aggregate query
      if query['expected_count']!=0
        assert query.aggregate_result != nil
        assert query.aggregate_result['count'] == query['expected_count']
      else
        assert query.aggregate_result == nil
      end
    end
  end

end