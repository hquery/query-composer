require 'test_helper'
require 'webrick'
require 'logger'

include GatewayUtils

class ExecutionTest < ActiveSupport::TestCase

  setup do
    dump_database
    @logger = Logger.new('log/rake')
    @user_with_functions = FactoryGirl.create(:user_with_queries_and_library_functions)
    
    library_function = @user_with_functions.library_functions[0]
    library_function.definition = library_function.definition.gsub(/username/,@user_with_functions.username)
    library_function.save
    
  end

  test "aggregation" do
    execution_to_aggregate = FactoryGirl.create(:query_with_completed_results).executions.first
    assert_nil execution_to_aggregate.aggregate_result
    execution_to_aggregate.aggregate
    
    assert_not_nil execution_to_aggregate.aggregate_result
    assert_equal 60, execution_to_aggregate.aggregate_result['F']
    assert_equal 100, execution_to_aggregate.aggregate_result['M']
  end
  
  test "aggregation for a generated query" do
    query = FactoryGirl.create(:generated_query_with_completed_results)
    query.generate_map_reduce
    query.reduce = full_reduce(query)
    execution_to_aggregate = query.executions.first
    assert_nil execution_to_aggregate.aggregate_result
    
    execution_to_aggregate.aggregate
    assert_not_nil execution_to_aggregate.aggregate_result
    
    assert_equal 24000, execution_to_aggregate.aggregate_result['Gender: F']['age']['sum']
    assert_equal 16000, execution_to_aggregate.aggregate_result['Gender: M']['age']['sum']
    assert_equal 1200, execution_to_aggregate.aggregate_result['Populations']['Target Population']
    assert_equal 1600, execution_to_aggregate.aggregate_result['Populations']['Filtered Population']
    assert_equal 400, execution_to_aggregate.aggregate_result['Populations']['Unfound Population']
    assert_equal 2000, execution_to_aggregate.aggregate_result['Populations']['Total Population']
  end

  test "query submission" do
    FakeWeb.register_uri(:post, HTTP_PROTO_CLIENT+"://127.0.0.1:3001/queries", :body => "Query Created",
                         :status => [201, "Created"], :location => HTTP_PROTO_CLIENT+"://127.0.0.1:3001/query/1234")
    FakeWeb.register_uri(:post, HTTP_PROTO_CLIENT+"://127.0.0.1:3001/library_functions", :body => "yay",
                         :status => [200, "OK"])

    user = FactoryGirl.create(:user)
    query = FactoryGirl.create(:query, user: user)
    endpoint = FactoryGirl.create(:endpoint)
    query.execute([endpoint])
    
    
    req =  FakeWeb.last_request  
    
    #check the request and make sure it was a multipart request
    # and that the map, reduce and filter if given are all file 
    # type parts
    assert req.kind_of?  Net::HTTP::Post::Multipart
    params = req.p
    assert params["map"].kind_of? UploadIO
    assert params["reduce"].kind_of? UploadIO
    if params["filter"]
      assert params["filter"].kind_of? UploadIO
    end
    
    result = query.last_execution.results[0]
    assert result
    assert_equal HTTP_PROTO_CLIENT+"://127.0.0.1:3001/query/1234", result.query_url
    assert_equal Result::QUEUED, result.status
  end
  
  

  
  
  test "query should log failures for endpoint on failure" do

    FakeWeb.register_uri(:post, HTTP_PROTO_CLIENT+"://127.0.0.1:3001/queries", :status => ["500", "Internal Server Error"])

    query = Query.find(@user_with_functions.queries[3].id)
    endpoint = FactoryGirl.create(:endpoint)
    query.execute([endpoint])

    assert_equal "Did not understand the response: 500 : Internal Server Error", endpoint.endpoint_logs[0].message
    
  end


  
  test "executions should only be finished if there are no queued results" do
    execution_with_incomplete_results = FactoryGirl.create(:query_with_queued_results).executions.first
    assert !execution_with_incomplete_results.finished?
    
    execution_with_complete_results = FactoryGirl.create(:query_with_completed_results).executions.first
    assert execution_with_complete_results.finished?
  end
  

  
end
