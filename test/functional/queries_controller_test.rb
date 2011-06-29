require 'test_helper'
include Devise::TestHelpers

class QueriesControllerTest < ActionController::TestCase
  
  setup  do 
    
    dump_database
    
    @user = Factory(:user_with_queries)
    @user_ids = [] << @user.id
    @ids = @user.queries.map {|q| q.id}
    
    @new_endpoint = Factory(:endpoint)
    
    @unattached_query = Factory(:query)
    
    @admin = Factory(:admin)
    
    @unapproved_user = Factory(:unapproved_user)
    
  end
  
  test "should get index" do
    sign_in @user
    get :index
    queries = assigns[:queries]
    assert_equal @user.queries, queries
    assert_response :success
  end

  test "should get index as admin" do
    sign_in @admin
    get :index
    queries = assigns[:queries]
    assert_equal Query.all, queries
    assert_response :success
  end


  test "should get new" do
    sign_in @user
    get :new
    assert_not_nil assigns[:query]
    assert_not_nil assigns[:endpoints]
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
    assert_not_nil query_from_db.endpoints
    assert_redirected_to(query_path(query.id))
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
    assert_response :success
  end

  test "should get show" do
    sign_in @user
    get :show, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_not_nil assigns[:endpoints]
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

  test "should remove endpoint" do
    sign_in @user
    query_from_db = Query.find(@ids[0])
    assert_not_equal query_from_db.title, 'Some title'
    assert_equal 2, query_from_db.endpoints.length
    post :update, id: @ids[0], query: { title: 'Some title', description: "Some description", endpoint_ids: [query_from_db.endpoints[0].id] }
    query = assigns(:query)
    assert_not_nil query
    query_from_db = Query.find(query.id)
    assert_not_nil query_from_db
    assert_equal 1, query_from_db.endpoints.length
    assert_response :success
    
  end

  test "should add endpoint" do
    sign_in @user
    query_from_db = Query.find(@ids[0])
    assert_not_equal query_from_db.title, 'Some title'
    assert_equal 2, query_from_db.endpoints.length
    post :update, id: @ids[0], query: { title: 'Some title', description: "Some description", endpoint_ids: [query_from_db.endpoints[0].id, query_from_db.endpoints[1].id, @new_endpoint.id] }
    query = assigns(:query)
    assert_not_nil query
    query_from_db = Query.find(query.id)
    assert_not_nil query_from_db
    assert_equal 3, query_from_db.endpoints.length
    assert_response :success
  end
  
  test "should execute query" do
    sign_in @user
    FakeWeb.register_uri(:post, "http://127.0.0.1:3001/queues", :body => "FORCE ERROR")
    query_from_db = Query.find(@ids[2])
    post :execute, id: @ids[2]
    query = assigns(:query)
    assert_not_nil query
    query_from_db = Query.find(@ids[2])
    
    # make sure results got cleared out
    assert_equal ({}), query_from_db.aggregate_result
    query_from_db.endpoints.each do |endpoint|
      assert_nil endpoint.result
    end
    
    assert_equal "POST", FakeWeb.last_request.method
    assert_equal "multipart/form-data", FakeWeb.last_request.content_type
    
    multipart_data = FakeWeb.last_request.body_stream.read
    
    assert_equal 1, (multipart_data.scan /name="map"/).length
    assert_equal 1, (multipart_data.scan /name="reduce"/).length
    assert_equal 1, (multipart_data.scan /name="filter"/).length
    
    assert_redirected_to(query_path(query.id))
    
  end
  
  test "log displays query log" do
    sign_in @user
    query_from_db = Query.find(@ids[1])
    query_logger = QueryLogger.new
    query_logger.add query_from_db, "test message"
    
    get :log, id: @ids[1]
    
    events = assigns[:events]
    assert_not_nil events
    assert "test message", events.last[:message]
  end
  
end
