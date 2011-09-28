require 'test_helper'
include Devise::TestHelpers

class QueriesControllerTest < ActionController::TestCase
  
  setup  do 
    
    dump_database
    
    @user = Factory(:user_with_queries)
    @ids = @user.queries.map {|q| q.id}
    @user_ids = [] << @user.id
    
    @new_endpoint = Factory(:endpoint)
    
    @endpoints_for_execution = []
    @endpoints_for_execution << Factory(:endpoint)
    @endpoints_for_execution << Factory(:endpoint, base_url: 'http://127.0.0.1:3002')
    
    @unattached_query = Factory(:query)
    
    @admin = Factory(:admin)
    
    @unapproved_user = Factory(:unapproved_user)
    
    @template_query = Factory(:template_query)
    
  end
  
  test "should get index" do
    sign_in @user
    get :index
    queries = assigns[:queries]
    assert_response :success
    
    assert_lists_equal @user.queries, queries
    
  end

  test "should get index as admin" do
    sign_in @admin
    get :index
    queries = assigns[:queries]
    assert_response :success
    
    assert_lists_equal Query.all, queries
  end


  test "should get new" do
    sign_in @user
    get :new
    assert_not_nil assigns[:query]
    assert_response :success
  end

  test "should create query" do
    sign_in @user
    post :create, query: { title: 'Some title', description: "Some description"}
    query = assigns(:query)
    assert_not_nil query
    query_from_db = Query.find(query.id)
    assert_not_nil query_from_db
    assert_equal query.title, 'Some title'
    assert_equal query.title, query_from_db.title
    assert_redirected_to(edit_query_path(query))
  end

  test "should update query" do
    sign_in @user
    query_from_db = Query.find(@ids[0])
    assert_not_equal query_from_db.title, 'Some title'
    post :update, id: @ids[0], query: { title: 'Some title', description: "Some description"}
    query = assigns(:query)
    assert_not_nil query
    query_from_db = Query.find(query.id)
    assert_not_nil query_from_db
    assert_equal query_from_db.title, 'Some title'
    assert_equal query.title, 'Some title'
    assert_redirected_to query_path(query)
  end

  test "should get show" do
    sign_in @user
    get :show, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_response :success
  end

  test "should get edit with non-generated query" do
    sign_in @user
    get :edit, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_redirected_to query_path(query) + "/edit_code"
  end

  test "should get edit with generated query" do
    sign_in @user
    query = Query.find(@ids[0])
    query.generated = true
    query.init_query_structure!
    query.save!
    get :edit, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_redirected_to query_path(query) + "/builder_simple"
    query.generated = false
    query.save!
  end

  test "should get edit code" do
    sign_in @user
    get :edit_code, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_response :success
  end

  test "should get edit code with generated query" do
    sign_in @user
    query = Query.find(@ids[0])
    query.generated = true
    query.init_query_structure!
    query.save!
    get :edit_code, id: @ids[0]
    cloned_query = assigns(:query)
    assert !cloned_query.generated?
    assert_not_equal @ids[0], cloned_query.id
    assert_equal "#{query.title} (cloned)", cloned_query.title
    assert_equal query.map, cloned_query.map
    assert_response :success
    query.generated = false
    query.save!
  end

  test "should get builder" do
    sign_in @user
    get :builder, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_response :success
  end

  test "should get builder simple" do
    sign_in @user
    get :builder_simple, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_response :success
  end

  test "should destroy query" do
    sign_in @user
    delete :destroy, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert (not Query.exists? :conditions => {id: @ids[0]})
    assert_redirected_to(queries_url)
  end

  test "should execute query with notification" do
    sign_in @user
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :body => "FORCE ERROR")
    query_from_db = Query.find(@ids[2])
    
    endpoint_ids = [@endpoints_for_execution[0].id.to_s]
    
    post :execute, id: @ids[2], endpoint_ids: endpoint_ids, notification: false
    query = assigns(:query)
    assert_not_nil query
    assert !query.last_execution.notification
    query_from_db = Query.find(@ids[2])
    
    # check that the query has an execution, and the execution has a result for each endpoint
    assert_not_nil query.executions
    assert_equal 1, query.executions.length
    assert_equal endpoint_ids.length, query.executions[0].results.length
    
    assert_equal "POST", FakeWeb.last_request.method
    assert_equal "multipart/form-data", FakeWeb.last_request.content_type
    
    multipart_data = FakeWeb.last_request.body_stream.read
    
    assert_equal 1, (multipart_data.scan /name="map"/).length
    assert_equal 1, (multipart_data.scan /name="reduce"/).length
    assert_equal 1, (multipart_data.scan /name="filter"/).length
    
    assert_redirected_to(query_path(query.id))
  end
  
  test "should execute query without notification" do
    sign_in @user
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :body => "FORCE ERROR")
    query_from_db = Query.find(@ids[2])
    
    endpoint_ids = [@endpoints_for_execution[0].id.to_s]
    
    post :execute, id: @ids[2], endpoint_ids: endpoint_ids, notification: true
    query = assigns(:query)
    assert_not_nil query
    assert query.last_execution.notification
    query_from_db = Query.find(@ids[2])
    
    # check that the query has an execution, and the execution has a result for each endpoint
    assert_not_nil query.executions
    assert_equal 1, query.executions.length
    assert_equal endpoint_ids.length, query.executions[0].results.length
    
    assert_equal "POST", FakeWeb.last_request.method
    assert_equal "multipart/form-data", FakeWeb.last_request.content_type
    
    multipart_data = FakeWeb.last_request.body_stream.read
    
    assert_equal 1, (multipart_data.scan /name="map"/).length
    assert_equal 1, (multipart_data.scan /name="reduce"/).length
    assert_equal 1, (multipart_data.scan /name="filter"/).length
    
    assert_redirected_to(query_path(query.id))
  end
  
  test "executing without endpoints should warn" do
    sign_in @user
    query = Query.find(@ids[2])

    post :execute, id: @ids[2], notification: true
    assert_redirected_to(query_path(query.id))
  end
  
  # test "log displays query log" do
  #   sign_in @user
  #   query_from_db = Query.find(@ids[1])
  #   query_logger = QueryLogger.new
  #   query_logger.add query_from_db, "test message"
  #   
  #   get :log, id: @ids[1]
  #   
  #   events = assigns[:events]
  #   assert_not_nil events
  #   assert "test message", events.last[:message]
  # end
  
  test "should check all queries completed" do
    sign_in @user
    get :show, id: @ids[0]
    query = assigns(:query)
    
    assert_equal @ids[0], query.id
    assert_response :success
  end
  
  test "should refresh execution with 0 pending" do
    sign_in @user
    # With no running queries, update_query_info should successfully return unfinished_query_count == 0
    query = Query.find(@ids[0])
    get :refresh_execution_results, id: query.id
    assert_equal false, assigns(:incomplete_results)
  end
  
  test "should refresh execution with 1 pending" do
    sign_in @user
    # One result's status will be 'Queued', so we should find that unfinished_query_count == 1
    query = Query.find(@ids[3])
    query.last_execution.results[0].status = Result::QUEUED
    query.save!
    get :refresh_execution_results, id: query.id
    assert_equal true, assigns(:incomplete_results)
  end
  
  test "should get execution history" do
    sign_in @user
    query = Query.find(@ids[4])
    get :execution_history, id: query.id
    assigned_query = assigns(:query);
    assert_not_nil assigned_query
    assert_response :success
  end
  
  
  test "should cancel endpoint results" do
    sign_in @user
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :body => "{}", :status => ["304"], :location=>"http://localhost:3001/queries")
    query_from_db = Query.find(@ids[2])
    
    endpoint_ids = [@endpoints_for_execution[0].id.to_s]
    
    # why is all of this here you ask, well becuse calling the method to post the execution actaully 
    # trys to call all of the endpoints which results in 
    post :execute, id: @ids[2], endpoint_ids: endpoint_ids, notification: true
    query = assigns(:query)
    assert_not_nil query
    assert query.last_execution.notification
    query_from_db = Query.find(@ids[2])
    
    # check that the query has an execution, and the execution has a result for each endpoint
    assert_not_nil query.executions
    assert_equal 1, query.executions.length
    assert_equal endpoint_ids.length, query.executions[0].results.length
    res_id = query.last_execution.results[0].id
    delete :cancel, id: @ids[2], execution_id: query.last_execution.id, result_id:res_id
    assert_equal Result::CANCELED, query.reload().last_execution.results.find(res_id).status
    assert_redirected_to(query_path(query.id))

  end
  
  
  test "should cancel execution" do
    sign_in @user
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queries", :body => "{}", :status => ["304"], :location=>"http://localhost:3001/queries")
    query_from_db = Query.find(@ids[2])

    endpoint_ids = [@endpoints_for_execution[0].id.to_s]
    
    # why is all of this here you ask, well becuse calling the method to post the execution actaully 
    # trys to call all of the endpoints which results in 
    post :execute, id: @ids[2], endpoint_ids: endpoint_ids, notification: true
    query = assigns(:query)
    assert_not_nil query
    assert query.last_execution.notification
    query_from_db = Query.find(@ids[2])
    
    # check that the query has an execution, and the execution has a result for each endpoint
    assert_not_nil query.executions
    assert_equal 1, query.executions.length
    assert_equal endpoint_ids.length, query.executions[0].results.length
    res_id = query.last_execution.results[0].id
    delete :cancel_execution, id: @ids[2], execution_id: query.last_execution.id
    assert_equal Result::CANCELED, query.reload().last_execution.results.find(res_id).status
    assert_redirected_to(query_path(query.id))

  end
  
  test "should clone template to query" do
    sign_in @user
    post :clone_template, template_id: @template_query.id
    query = assigns(:query)
    assert_not_nil query
    assert_equal "#{@template_query.title} (cloned)", query.title
    assert_equal @template_query.description, query.description
    assert_equal @template_query.filter, query.filter
    assert_equal @template_query.map, query.map
    assert_equal @template_query.reduce, query.reduce
    assert_response :success
  end
  
end
