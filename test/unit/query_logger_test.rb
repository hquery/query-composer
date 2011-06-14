require 'test_helper'

class QueryLoggerTest < ActiveSupport::TestCase

  setup do
    @ids = collection_fixtures('queries')
  end

  test "Query Logger" do
    query_from_db = Query.find(@ids[1])
    
    query_logger = QueryLogger.new
    query_logger.add query_from_db, "test message"
    
    query_log = query_logger.log(query_from_db.id)
    assert_equal 1, query_log.length
    assert_equal query_from_db.id, query_log[0]['query']
    assert_equal 'test message', query_log[0]['message']
    assert_not_nil query_log[0]['time']
    
    query_logger.add query_from_db, "test message 2"

    assert_equal 2, query_logger.log(query_from_db.id).length
    
  end

end