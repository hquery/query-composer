require 'test_helper'

class PollJobTest < ActiveSupport::TestCase

  setup do
     
    dump_database
    dump_jobs
    
    @user = Factory(:user_with_queries)
    @user_with_functions = Factory(:user_with_queries_and_library_functions)
    @ids = @user.queries.map {|q| q.id}
    
    @query_w_result = @user.queries[3]
    @query_to_aggregate = @user.queries[4]
    
    library_function = @user_with_functions.library_functions[0]
    library_function.definition = library_function.definition.gsub(/username/,@user_with_functions.username)
    library_function.save
    
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
      assert_equal Result::QUEUED, result.status
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
      assert_equal Result::FAILED, result.status
      assert_equal "Internal Server Error", result.error_msg
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
  
  
  
  
  
  test "Poll job should cancel jobs" do
    FakeWeb.register_uri(:get, "http://127.0.0.1:3001/queues", :body => "{\"foo\" : \"bar\"}")
    FakeWeb.register_uri(:delete, "http://127.0.0.1:3001/queues", :body => "Job Canceled")
    query_from_db = Query.find(@query_w_result.id)
    
    # set the result urls to the submit urls... this would typically happend as part of the poll job submit process
    query_from_db.executions[0].results.each {|result| result.result_url = result.endpoint.submit_url}
    query_from_db.save!
    query_from_db.executions[0].cancel
    query_from_db.executions[0].results.each do |result| 
      poll_job = PollJob.new query_from_db.id.to_s, query_from_db.executions[0].id.to_s, result.id.to_s
      poll_job.perform
    end
    
    query_from_db = Query.find(@query_w_result.id)
    
    query_from_db.executions[0].results.each do |result|
      query_logger = QueryLogger.new
      query_log = query_logger.log(query_from_db.id)
      found = query_log.find {|log| log["message"] <=> "Results canceled for result id #{result.id}"}
      assert_not_nil found
    end

  end
  
  
  
  test "poll job should submit properly with library functions" do
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :body => "complete")
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queues", :body => "{\"foo\" : \"bar\"}")
    query_from_db = Query.find(@user_with_functions.queries[3].id)

    PollJob.submit_all(query_from_db.executions[0])

    db = Mongoid::Config.master
    assert_equal 'hquery_user_functions', db['system.js'].find({}).first['_id']
    assert_not_nil db['system.js'].find({}).first['value']['f'+COMPOSER_ID]['f'+@user_with_functions.id.to_s]['sum']
  end

  test "poll job should submit properly with exiting library functions defined" do
    
    # add some existing data at the composer level
    db = Mongoid::Config.master
    user_namespace = "hquery_user_functions = {}; hquery_user_functions['foobar'] = {};"
    db.eval(user_namespace)
    db.eval("db.system.js.save({_id:'hquery_user_functions', value : hquery_user_functions })")
    
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :body => "complete")
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queues", :body => "{\"foo\" : \"bar\"}")
    query_from_db = Query.find(@user_with_functions.queries[3].id)

    PollJob.submit_all(query_from_db.executions[0])

    db = Mongoid::Config.master
    assert_equal 'hquery_user_functions', db['system.js'].find({}).first['_id']
    # make sure we have not blown away the existing data
    assert_not_nil db['system.js'].find({}).first['value']['foobar']
    # make sure the new stuff is there as well
    assert_not_nil db['system.js'].find({}).first['value']['f'+COMPOSER_ID]['f'+@user_with_functions.id.to_s]['sum']
  end
  
  test "poll job with library functions should log communication error saving functions" do
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/library_functions", :status => ["500", "Internal Server Error"])
    query_from_db = Query.find(@user_with_functions.queries[3].id)

    PollJob.submit_all(query_from_db.executions[0])
    
    assert_equal "library functions failed", Event.all[0].message
    
  end

  test "poll job with library functions should log exception saving functions" do

    # alias the method so that we can restore it... mocha should do this but turn is causing issues currently
    class Net::HTTP
    class << self
      alias unmocked_start start
    end
    end
    
    Net::HTTP.expects(:start).raises(SocketError, 'getaddrinfo: nodename nor servname provided, or not known')
    
    query_from_db = Query.find(@user_with_functions.queries[3].id)
    query_from_db.endpoints.each { | endpoint | endpoint.base_url = "http://localhost:3001/"; endpoint.save; }
    query_from_db.reload

    PollJob.submit_all(query_from_db.executions[0])

    # restore original method
    class Net::HTTP
    class << self
      alias start unmocked_start
    end
    end
    
    assert (Event.all.map{|x| x.message}).include? 'library functions exception'
    
  end
  

end
