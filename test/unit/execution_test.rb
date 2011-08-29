require 'test_helper'

class ExecutionTest < ActiveSupport::TestCase

  setup do
    dump_database
  end

  test "aggregation" do
    execution_to_aggregate = Factory.create(:query_with_completed_results).executions.first
    assert_nil execution_to_aggregate.aggregate_result
    execution_to_aggregate.aggregate
    assert_not_nil execution_to_aggregate.aggregate_result
    assert_equal 60, execution_to_aggregate.aggregate_result['F'];
    assert_equal 100, execution_to_aggregate.aggregate_result['M'];
  end

  test "query submission" do
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :body => "Query Created",
                         :status => [201, "Created"], :location => "http://127.0.0.1:3001/query/1234")
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :body => "yay",
                         :status => [200, "OK"])

    query = Factory.create(:query)
    endpoint = Factory.create(:endpoint)
    query.execute([endpoint])
    result = Result.first
    assert result
    assert_equal "http://127.0.0.1:3001/query/1234", result.query_url
    assert_equal Result::QUEUED, result.status
  end
  
  test "posting library functions" do
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :body => "complete")
    endpoint = Factory.create(:endpoint)
    user = Factory.create(:user_with_library_functions)
    execution = Execution.new
    assert_equal 0, endpoint.endpoint_logs.count
    execution.post_library_function(endpoint, user)
    assert_equal 1, endpoint.endpoint_logs.count
    el = endpoint.endpoint_logs.first
    assert el
    assert_equal :user_functions, el.status
    assert_equal "user functions inserted", el.message
  end
end
