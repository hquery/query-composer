require 'test_helper'
require 'delayed/command'
require 'endpoint_cron_job'

class EndpointCronTest < ActiveSupport::TestCase
  setup do
    dump_database
    
  end
  
  test "cron job works" do 
    cronJob = EndpointCronJob.new
    #to make sure we dont run into an infinite loop need to set delay_jobs to true
    # else everytime a job is added it get invoked immeadiatly.  And as the cronJob
    # enques a job everytime it runs we would just be spinning here.
    Delayed::Worker.delay_jobs = true
    job = Delayed::Job.enqueue payload_object: cronJob, run_at: 2.from_now

    
    FakeWeb.register_uri(:get, HTTP_PROTO_CLIENT+"://127.0.0.1:3001/queries",
                     :body => File.read(File.expand_path('../../fixtures/query_feed.xml', __FILE__)))
    FakeWeb.register_uri(:get, HTTP_PROTO_CLIENT+"://localhost:3000/queries/4e4c08b5431a5f5dc1000001",
                     :body => '{"status": "queued"}')
    endpoint = FactoryGirl.create(:endpoint)
    result = FactoryGirl.create(:result_waiting, endpoint: endpoint)
    result_updated_at = result.updated_at
    assert_equal 0, endpoint.endpoint_logs.count
    assert ! endpoint.last_check
    
    #invoking the job should cuase the cronJob to execute and then to
    # reschedule itself once it's done.  After which we can see if the 
    # endpoint was checked to make sure that it ran.
    
    job.invoke_job 
    
    # need to reload this as it gets updated in the cron job
    endpoint.reload
    assert endpoint.last_check
    assert_equal 1, endpoint.endpoint_logs.count
    el = endpoint.endpoint_logs.first
    assert el
    assert_equal :update, el.status
      
    newJob = Delayed::Job.last
    assert newJob != job
    assert newJob.payload_object.kind_of? EndpointCronJob
  end

end