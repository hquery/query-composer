require 'test_helper'
include Devise::TestHelpers

class EndpointsControllerTest < ActionController::TestCase
  setup do
    dump_database
    
    @admin = Factory(:admin)
    
    @endpoint = Factory(:endpoint)
    @endpoint_unsaved = Factory.build(:endpoint)
    
    sign_in @admin
    
    @user = Factory(:user_with_queries)
    @ids = @user.queries.map {|q| q.id}
    
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:endpoints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create endpoint" do
    assert_difference('Endpoint.count') do
      post :create, endpoint: @endpoint_unsaved.attributes
    end

    assert_redirected_to endpoint_path(assigns(:endpoint))
  end

  test "should not create endpoint without required fields" do
    # make sure that base_url is required
    post :create, endpoint: {name: "blah"}
    invalid_endpoint = assigns[:endpoint]
    assert_not_nil invalid_endpoint
    assert !invalid_endpoint.valid?
    assert invalid_endpoint.errors[:name].empty?
    assert !invalid_endpoint.errors[:base_url].empty?
    assert_response :success
    
  end
  
  test "endpoint name should be required" do
    #make sure that name is also required
    post :create, endpoint: {base_url: "blah"}
    invalid_endpoint = assigns[:endpoint]
    assert !invalid_endpoint.valid?
    assert !invalid_endpoint.errors[:name].empty?
    assert invalid_endpoint.errors[:base_url].empty?
    assert_response :success
  end

  test "should show endpoint" do
    get :show, id: @endpoint.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @endpoint.to_param
    assert_response :success
  end

  test "should update endpoint" do
    put :update, id: @endpoint.to_param, endpoint: @endpoint.attributes
    assert_redirected_to endpoint_path(assigns(:endpoint))
  end

  test "should not update endpoint if invalid" do
    # make sure we can't update to be invalid
    put :update, id: @endpoint.to_param, endpoint: {base_url: nil}
    invalid_endpoint = assigns[:endpoint]
    assert_not_nil invalid_endpoint
    assert !invalid_endpoint.valid?
    assert invalid_endpoint.errors[:name].empty?
    assert !invalid_endpoint.errors[:base_url].empty?
    assert_response :success

  end

  test "should destroy endpoint" do
    assert_difference('Endpoint.count', -1) do
      delete :destroy, id: @endpoint.to_param
    end

    assert_redirected_to endpoints_path
  end
  
  test "should refresh endpoint statuses" do
    FakeWeb.register_uri(:get, "http://127.0.0.1:3001/queues/server_status", :body => 
      "{\"queued\":0,\"running\":0,\"successful\":331,\"failed\":0,\"retried\":0,\"avg_runtime\":4.54074623361455,\"backend_status\":\"good\"}")
    get :refresh_endpoint_statuses

    assert_equal "GET", FakeWeb.last_request.method
    assert_equal 11, assigns[:endpoint_server_statuses].size
    assert_equal 'good', assigns[:endpoint_server_statuses][Endpoint.all[0].id][:backend_status]
  end
  
  test "should gracefully refresh downed endpoint status" do
    Endpoint.all.each do |endpoint|
      endpoint.base_url = "http://something.totally.invalid:9999"
      endpoint.save!
    end
    get :refresh_endpoint_statuses
    assert_equal 11, assigns[:endpoint_server_statuses].size
    assert_equal 'unreachable', assigns[:endpoint_server_statuses][Endpoint.all[0].id][:backend_status]
  end
  
end
