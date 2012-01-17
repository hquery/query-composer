require 'test_helper'
require 'webrick'
require 'logger'
include GatewayUtils
class ExecutionTest < ActiveSupport::TestCase

  setup do
    dump_database
    @logger = Logger.new('log/rake')
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
  
end
