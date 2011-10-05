require 'test_helper'

class EndpointTest < ActiveSupport::TestCase
  setup do
    dump_database
  end
  
  test "monitoring queries that have not been modified" do
    FakeWeb.register_uri(:get, "http://127.0.0.1:3001/queries",
                         :status => [304, "Not Modified"])

    endpoint = Factory.create(:endpoint)
    assert_equal 0, endpoint.endpoint_logs.count
    assert ! endpoint.last_check
    endpoint.check
    assert endpoint.last_check
    assert_equal 1, endpoint.endpoint_logs.count
    el = endpoint.endpoint_logs.first
    assert el
    assert_equal :not_modified, el.status
  end
  
  test "monitoring queries that have changed" do
    FakeWeb.register_uri(:get, "http://127.0.0.1:3001/queries",
                         :body => File.read(File.expand_path('../../fixtures/query_feed.xml', __FILE__)))
    FakeWeb.register_uri(:get, "http://localhost:3000/queries/4e4c08b5431a5f5dc1000001",
                         :body => '{"status": "queued"}')
    endpoint = Factory.create(:endpoint)
    result = Factory.create(:result_waiting, endpoint: endpoint)
    result_updated_at = result.updated_at
    assert_equal 0, endpoint.endpoint_logs.count
    assert ! endpoint.last_check
    endpoint.check
    assert endpoint.last_check
    assert_equal 1, endpoint.endpoint_logs.count
    el = endpoint.endpoint_logs.first
    assert el
    assert_equal :update, el.status
    result.reload
    assert result_updated_at != result.updated_at
  end
  
  test "monitoring queries with incomprehensible responses" do
    
  end
  
  test "check if there are active queries" do
    endpoint = Factory.create(:endpoint)
    Factory.create(:result_with_value, endpoint: endpoint)
    assert !endpoint.unfinished_results?
    Factory.create(:result_waiting, endpoint: endpoint)
    assert endpoint.unfinished_results?
  end
  
  test "should gracefully handle errors in check" do
    
  end
  
  test "should update last check time" do
    
  end
  
  test "should return an execution given a result" do
    
  end
  
  test "should aggregate results upon query completion" do

  end
end
