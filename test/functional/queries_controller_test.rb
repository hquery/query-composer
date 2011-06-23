require 'test_helper'
include Devise::TestHelpers

class QueriesControllerTest < ActionController::TestCase
  
  setup  do 
    @user_ids = setup_users()
    @user = User.find(@user_ids[0])
    sign_in @user
    @ids = collection_fixtures('queries', @user)
  end
  
  teardown do
      user = User.where({email: 'testuser@test.com'})[0]
      user.destroy
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create query" do
    post :create, query: { title: 'Some title', description: "Some description"}
    query = assigns(:query)
    assert_not_nil query
    query_from_db = Query.find(query.id)
    assert_not_nil query_from_db
    assert_equal query.title, 'Some title'
    assert_equal query.title, query_from_db.title
    assert_not_nil query_from_db.endpoints
    assert_equal 1, query_from_db.endpoints.length
    assert_redirected_to(query_path(query.id))
  end

  test "should update query" do
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
    get :show, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert_response :success
  end

  test "should destroy query" do
    delete :destroy, id: @ids[0]
    query = assigns(:query)
    assert_equal @ids[0], query.id
    assert (not Query.exists? :conditions => {id: @ids[0]})
    assert_redirected_to(queries_url)
  end

  test "should destroy endpoint" do
    query_from_db = Query.find(@ids[1])
    num_endpoints = query_from_db.endpoints.length
    id_to_delete = query_from_db.endpoints[0].id
    delete :destroy_endpoint, id: query_from_db.id, endpoint: {id: id_to_delete}
    query = assigns(:query)
    assert_equal @ids[1], query.id
    query_from_db = Query.find(@ids[1])
    assert (query_from_db.endpoints.select {|endpoint| endpoint.id == id_to_delete}).empty?
    assert_equal num_endpoints-1, query_from_db.endpoints.length
    assert_response :success
  end

  test "should update endpoint" do
    query_from_db = Query.find(@ids[1])
    endpoint = query_from_db.endpoints[0]
    assert_not_equal 'modified url', endpoint.submit_url
    put :update_endpoint, id: query_from_db.id, endpoint: {id: endpoint.id, submit_url: 'modified url'}
    query = assigns(:query)
    assert_equal @ids[1], query.id
    query_from_db = Query.find(@ids[1])
    updated_endpoint = (query_from_db.endpoints.select {|e| e.id == endpoint.id})[0]
    assert_equal 'modified url', updated_endpoint.submit_url
    assert_response :success
  end

  test "should add endpoint" do
    query_from_db = Query.find(@ids[1])
    existing_ids = query_from_db.endpoints.collect {|endpoint| endpoint.id}
    post :add_endpoint, id: query_from_db.id
    query = assigns(:query)
    assert_equal @ids[1], query.id
    query_from_db = Query.find(@ids[1])
    assert_equal existing_ids.length + 1, query_from_db.endpoints.length
    new_endpoint = (query_from_db.endpoints.select {|endpoint| (not existing_ids.include? endpoint.id) })[0]
    assert_equal 'Default Local Queue', new_endpoint.name
    assert_equal 'http://localhost:3001/queues', new_endpoint.submit_url
    assert_nil new_endpoint.result_url
    assert_nil new_endpoint.next_poll
    assert_nil new_endpoint.result
    assert_response :success
  end
  
  test "should execute query" do
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
    query_from_db = Query.find(@ids[1])
    query_logger = QueryLogger.new
    query_logger.add query_from_db, "test message"
    
    get :log, id: @ids[1]
    
    events = assigns[:events]
    assert_not_nil events
    assert "test message", events.last[:message]
  end
  

end
