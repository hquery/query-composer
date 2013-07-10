require 'test_helper'
include GatewayUtils

class GatewayUtilsTest < ActiveSupport::TestCase
  setup do
    dump_database
  end
  
  test "generated queries should fetch javascript libraries" do
    query = FactoryGirl.create(:generated_query_with_completed_results)
    query.generate_map_reduce
    
    full_map = full_map(query)
    assert full_map.include?("function map(patient)"), "does not include map "
   
    
    
    full_reduce = full_reduce(query)
    assert full_reduce.include? "function reduce(key, values)"
    assert full_reduce.include? "reducer = this.reducer || {};"
    
    functions = build_library_functions(query)
    assert functions.include?( "var queryStructure = queryStructure || {}"), "does not include query structure "
    assert functions.include?( "reducer = this.reducer || {};"), "does not include reducer "
  end
end