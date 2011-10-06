require 'test_helper'
include GatewayUtils

class ExecutionTest < ActiveSupport::TestCase

  setup do
    dump_database
    
    @user_with_functions = Factory(:user_with_queries_and_library_functions)
    
    library_function = @user_with_functions.library_functions[0]
    library_function.definition = library_function.definition.gsub(/username/,@user_with_functions.username)
    library_function.save
    
  end

  test "aggregation" do
    execution_to_aggregate = Factory.create(:query_with_completed_results).executions.first
    assert_nil execution_to_aggregate.aggregate_result
    execution_to_aggregate.aggregate
    
    assert_not_nil execution_to_aggregate.aggregate_result
    assert_equal 60, execution_to_aggregate.aggregate_result['F']
    assert_equal 100, execution_to_aggregate.aggregate_result['M']
  end
  
  test "aggregation for a generated query" do
    query = Factory.create(:generated_query_with_completed_results)
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
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :body => "Query Created",
                         :status => [201, "Created"], :location => "http://127.0.0.1:3001/query/1234")
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :body => "yay",
                         :status => [200, "OK"])

    user = Factory.create(:user)
    query = Factory.create(:query, user: user)
    endpoint = Factory.create(:endpoint)
    query.execute([endpoint])
    result = query.last_execution.results[0]
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
  
  test "query should execute properly with library functions" do
    
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :body => "complete")
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :body => "{\"foo\" : \"bar\"}")
    query = Query.find(@user_with_functions.queries[3].id)
  
    query.execute([Factory.create(:endpoint)])
  
    db = Mongoid::Config.master
    assert_equal 'hquery_user_functions', db['system.js'].find({}).first['_id']
    assert_not_nil db['system.js'].find({}).first['value']['f'+COMPOSER_ID]['f'+@user_with_functions.id.to_s]['sum']
  end
  
  test "query should execute properly with exiting library functions defined" do
    
    # add some existing data at the composer level
    db = Mongoid::Config.master
    user_namespace = "hquery_user_functions = {}; hquery_user_functions['foobar'] = {};"
    db.eval(user_namespace)
    db.eval("db.system.js.save({_id:'hquery_user_functions', value : hquery_user_functions })")
    
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :body => "complete")
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :body => "{\"foo\" : \"bar\"}")
    query = Query.find(@user_with_functions.queries[3].id)
  
    query.execute([Factory.create(:endpoint)])
  
    db = Mongoid::Config.master
    assert_equal 'hquery_user_functions', db['system.js'].find({}).first['_id']
    # make sure we have not blown away the existing data
    assert_not_nil db['system.js'].find({}).first['value']['foobar']
    # make sure the new stuff is there as well
    assert_not_nil db['system.js'].find({}).first['value']['f'+COMPOSER_ID]['f'+@user_with_functions.id.to_s]['sum']
  end
  
  test "query should log failures for endpoint and library function on failure" do
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :status => ["500", "Internal Server Error"])
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :status => ["500", "Internal Server Error"])

    query = Query.find(@user_with_functions.queries[3].id)
    endpoint = Factory.create(:endpoint)
    query.execute([endpoint])
    assert_equal "user functions failed", endpoint.endpoint_logs[0].message
    assert_equal "Did not understand the response: 500 : Internal Server Error", endpoint.endpoint_logs[1].message
    
  end

  test "query with library functions should log exception saving functions" do
  
    # alias the method so that we can restore it... mocha should do this but turn is causing issues currently
    class Net::HTTP
      class << self
        alias unmocked_start start
      end
    end
    
    Net::HTTP.expects(:start).raises(SocketError, 'getaddrinfo: nodename nor servname provided, or not known')
    
    query = Query.find(@user_with_functions.queries[3].id)
  
    endpoint = Factory.create(:endpoint)
    query.execute([endpoint])
  
    # restore original method
    class Net::HTTP
    class << self
      alias start unmocked_start
    end
    end
    
    assert_equal "user functions failed: getaddrinfo: nodename nor servname provided, or not known", endpoint.endpoint_logs[0].message
    assert_equal "Exception submitting endpoint: getaddrinfo: nodename nor servname provided, or not known", endpoint.endpoint_logs[1].message
    
  end
  
  test "executions should only be finished if there are no queued results" do
    execution_with_incomplete_results = Factory.create(:query_with_queued_results).executions.first
    assert !execution_with_incomplete_results.finished?
    
    execution_with_complete_results = Factory.create(:query_with_completed_results).executions.first
    assert execution_with_complete_results.finished?
  end
end
