require 'test_helper'

class PollJobTest < ActiveSupport::TestCase

  setup do
    @ids = collection_fixtures('queries')
  end

  test "Aggregation" do
    queries = Query.all.to_a
    assert queries.size==3
    queries.each do |query|
      PollJob.aggregate query
      if query['exected_count'] && query['expected_count']!=0
        assert query.aggregate_result != nil
        assert query.aggregate_result["null"]['count'] == query['expected_count']
      elsif query['expected_count'] == 0
        assert query.aggregate_result.size == 0
      end
    end
  end

  test "submit poll job and deal with success properly" do
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queues", :body => "{\"foo\" : \"bar\"}")
    query_from_db = Query.find(@ids[2])

    PollJob.submit_all(query_from_db)

    query_from_db = Query.find(@ids[2])

    query_from_db.endpoints.each do |endpoint|
      assert_equal 'Complete', endpoint.status
      assert_equal ({"foo" => 'bar'}), endpoint.result
      assert_nil endpoint.next_poll
      assert_nil endpoint.result_url

      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      assert_equal "Complete", query_log.last["message"]
    end
  end

  test "submit poll job and deal with redirect properly" do
    query_from_db = Query.find(@ids[2])
    FakeWeb.register_uri(:post, query_from_db.endpoints[0].submit_url, :status => ["302", "Found"], location: 'http://result_url/', "retry-after" => 15)

    Delayed::Job.destroy_all
    assert Delayed::Job.all.count == 0 

    PollJob.submit_all(query_from_db)

    query_from_db = Query.find(@ids[2])

    query_from_db.endpoints.each do |endpoint|
      assert_equal 'Queued', endpoint.status
      assert_equal 'http://result_url/', endpoint.result_url
      assert_equal 15, endpoint.next_poll
      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      assert_equal "Queued", query_log.last["message"]
    end
    assert Delayed::Job.all.count == 1

  end 

  test "submit poll job and deal with error properly" do
    query_from_db = Query.find(@ids[2])
    FakeWeb.register_uri(:post, query_from_db.endpoints[0].submit_url, :status => ["500", "Internal Server Error"])

    PollJob.submit_all(query_from_db)

    query_from_db = Query.find(@ids[2])

    query_from_db.endpoints.each do |endpoint|
      assert_equal "Internal Server Error", endpoint.status
      assert_nil endpoint.result_url
      assert_nil endpoint.next_poll

      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      assert_equal "Failed", query_log.last["message"]

    end

  end 

  test "Poll job run should poll properly when run" do
    FakeWeb.register_uri(:get, "http://127.0.0.1:3001/queues", :body => "{\"foo\" : \"bar\"}")
    query_from_db = Query.find(@ids[2])

    # set the result url properly for poll
    query_from_db.endpoints[0].result_url = 'http://127.0.0.1:3001/queues'
    query_from_db.save!

    poll_job = PollJob.new query_from_db.id.to_s, query_from_db.endpoints[0].id.to_s
    poll_job.perform

    query_from_db = Query.find(@ids[2])

    query_from_db.endpoints.each do |endpoint|
      assert_equal 'Complete', endpoint.status
      assert_equal ({"foo" => 'bar'}), endpoint.result
      assert_nil endpoint.next_poll
      assert_nil endpoint.result_url

      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      assert_equal "Complete", query_log.last["message"]
    end


  end

end
