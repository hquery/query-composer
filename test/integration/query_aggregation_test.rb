require 'test_helper'
include GatewayUtils

class QueryAggregation < ActionDispatch::IntegrationTest

  setup do
    dump_database
    
    @query = FactoryGirl(:generated_query_with_completed_results)
    @query.generate_map_reduce
    @query.reduce = full_reduce(@query)
    
    @execution_to_aggregate = @query.executions.first
    @execution_to_aggregate.aggregate
  end
  
  test "attempting to aggregate results with no matching execution should be handled gracefully" do
    # Not generated
    
    # Generated
    
  end

  test "sum should perform properly" do
    assert_equal 16000, @execution_to_aggregate.aggregate_result['Gender: M']['age']['sum']
    assert_equal 24000, @execution_to_aggregate.aggregate_result['Gender: F']['age']['sum']
    
    # 1 result
    single_result = FactoryGirl.create(:generated_query_with_single_result)
    single_result.executions.first.aggregate
    assert_equal 4000, single_result.executions.first.aggregate_result['Gender: M']['age']['sum']
    assert_equal 6000, single_result.executions.first.aggregate_result['Gender: F']['age']['sum']
  end
  
  test "frequency should perform properly" do
    
    
    # 1 result
  end
  
  test "mean should perform properly" do
    
    
    # 1 result
  end
  
  test "median should perform properly" do
    # Even number of results
    
    # Odd number of results
    
    # 1 result
  end
  
  test "mode should perform properly" do
    
    
    # 1 result
  end
end