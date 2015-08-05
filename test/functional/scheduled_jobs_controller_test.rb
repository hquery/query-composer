require 'test_helper'

class ScheduledJobsControllerTest < ActionController::TestCase


  setup  do

    dump_database

    @user = FactoryGirl.create(:user_with_queries)
    @ids = @user.queries.order_by([[:created_at, :desc]]).map {|q| q.id}
    @user_ids = [] << @user.id

    @new_endpoint = FactoryGirl.create(:endpoint)

    @endpoints_for_execution = []
    @endpoints_for_execution << FactoryGirl.create(:endpoint)
    @endpoints_for_execution << FactoryGirl.create(:endpoint, base_url: HTTP_PROTO_CLIENT+'://127.0.0.1:3002')

    @unattached_query = FactoryGirl.create(:query)

    @admin = FactoryGirl.create(:admin)

    @unapproved_user = FactoryGirl.create(:unapproved_user)

    @template_query = FactoryGirl.create(:template_query)

  end

  test 'should get batch_query' do
    sign_in @user
    FakeWeb.register_uri(:post, HTTP_PROTO_CLIENT+"://127.0.0.1:3001/queries", :body => "FORCE ERROR")
    query_from_db = Query.find(@ids[2])

    endpoint_ids = [@endpoints_for_execution[0].id.to_s]

    puts "endpoints: " + @endpoints_for_execution.inspect

    #STDERR.puts query_from_db.inspect
    puts "DRUSK #{endpoint_ids}"
    puts "@ids[2]=" + @ids[2].inspect + " endpoint_ids=" + endpoint_ids.inspect
    post :batch_query, id: @ids[2], endpoint_ids: endpoint_ids, notification: false
    #query = assigns(:query)
    #assert_not_nil query
    #assert query.last_execution.notification
    assert_response :success
  end

end
