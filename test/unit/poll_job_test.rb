require 'test_helper'

class PollJobTest < ActiveSupport::TestCase

  setup do
     
    dump_database
    dump_jobs
    
    @user = Factory(:user_with_queries)
    @ids = @user.queries.map {|q| q.id}
    
    @query_w_result = Factory(:query_with_execution)
    @query_to_aggregate = Factory(:query_with_completed_results)
    
  end

  test "Aggregation" do
    assert_nil @query_to_aggregate.executions[0].aggregate_result
    PollJob.aggregate @query_to_aggregate.executions[0]
    assert_not_nil @query_to_aggregate.executions[0].aggregate_result
    assert_equal 60, @query_to_aggregate.executions[0].aggregate_result['F'];
    assert_equal 100, @query_to_aggregate.executions[0].aggregate_result['M'];
  end

  test "submit poll job and deal with success properly" do
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queues", :body => "{\"foo\" : \"bar\"}")
    query_from_db = Query.find(@query_w_result.id)

    query_from_db.executions[0].notification = true
    query_from_db.user_id = @user.id
    PollJob.submit_all(query_from_db.executions[0])

    query_from_db = Query.find(@query_w_result.id)

    query_from_db.executions[0].results.each do |result| 
      result.execution.notification = true
      assert_equal 'Complete', result.status
      assert_equal ({"foo" => 'bar'}), result.value
      assert_nil result.next_poll
      assert_nil result.result_url

      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      assert_equal "Complete", query_log.last["message"]
    end
    
    mail = ActionMailer::Base.deliveries.last
    assert_equal "[hQuery] Results for #{query_from_db.title}", mail.subject
  end

  test "submit poll job and deal with redirect properly" do
    query_from_db = Query.find(@query_w_result.id)
    FakeWeb.register_uri(:post, query_from_db.endpoints[0].submit_url, :status => ["302", "Found"], location: 'http://result_url/', "retry-after" => 15)

    Delayed::Job.destroy_all
    assert Delayed::Job.all.count == 0 

    PollJob.submit_all(query_from_db.executions[0])

    query_from_db = Query.find(@query_w_result.id)

    query_from_db.executions[0].results.each do |result|
      assert_equal 'Queued', result.status
      assert_equal 'http://result_url/', result.result_url
      assert_equal 15, result.next_poll
      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      assert_equal "Queued", query_log.last["message"]
    end
    assert Delayed::Job.all.count == query_from_db.endpoints.count

  end 

  test "submit poll job and deal with error properly" do
    query_from_db = Query.find(@query_w_result.id)
    FakeWeb.register_uri(:post, query_from_db.endpoints[0].submit_url, :status => ["500", "Internal Server Error"])

    PollJob.submit_all(query_from_db.executions[0])

    query_from_db = Query.find(@query_w_result.id)

    query_from_db.executions[0].results.each do |result|
      assert_equal "Internal Server Error", result.status
      assert_nil result.result_url
      assert_nil result.next_poll

      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      assert_equal "Failed", query_log.last["message"]

    end

  end 

  test "Poll job run should poll properly when run" do
    FakeWeb.register_uri(:get, "http://127.0.0.1:3001/queues", :body => "{\"foo\" : \"bar\"}")
    query_from_db = Query.find(@query_w_result.id)
    
    # set the result urls to the submit urls... this would typically happend as part of the poll job submit process
    query_from_db.executions[0].results.each {|result| result.result_url = result.endpoint.submit_url}
    query_from_db.save!

    query_from_db.executions[0].results.each do |result| 
      poll_job = PollJob.new query_from_db.id.to_s, query_from_db.executions[0].id.to_s, result.id.to_s
      poll_job.perform
    end

    query_from_db = Query.find(@query_w_result.id)

    query_from_db.executions[0].results.each do |result|
      assert_equal 'Complete', result.status
      assert_equal ({"foo" => 'bar'}), result.value
      assert_nil result.next_poll
      assert_nil result.result_url

      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      assert_equal "Complete", query_log.last["message"]
    end


  end

end
