require 'test_helper'
include Devise::TestHelpers

class EndpointsControllerTest < ActionController::TestCase
  setup do
    dump_database
    
    @admin = FactoryGirl.create(:admin)
    
    @endpoint = FactoryGirl.create(:endpoint)
    @endpoint_unsaved = FactoryGirl.build(:endpoint)
    
    sign_in @admin
    
    @user = FactoryGirl.create(:user_with_queries)
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
    if SslConfig::getUseSslClient
    FakeWeb.register_uri(:get, "https://127.0.0.1:3001/queries", :body =>
     %{<?xml version="1.0" encoding="UTF-8"?>
     <feed xmlns="http://www.w3.org/2005/Atom" xmlns:md="http://projecthdata.org/hdata/schemas/2009/11/metadata">
       <title>Distributed Queries</title>
       <link href="https://localhost:3001/hdata/index"/>
       <updated>2011-12-15T16:02:13-05:00</updated>
       <author>
         <name>hQuery Gateway</name>
       </author>
       <id>https://localhost:3001/queries</id>
     </feed>})
    else
      FakeWeb.register_uri(:get, "http://127.0.0.1:3001/queries", :body =>
          %{<?xml version="1.0" encoding="UTF-8"?>
     <feed xmlns="http://www.w3.org/2005/Atom" xmlns:md="http://projecthdata.org/hdata/schemas/2009/11/metadata">
       <title>Distributed Queries</title>
       <link href="http://localhost:3001/hdata/index"/>
       <updated>2011-12-15T16:02:13-05:00</updated>
       <author>
         <name>hQuery Gateway</name>
       </author>
       <id>http://localhost:3001/queries</id>
     </feed>})
    end
    get :refresh_endpoint_statuses

    assert_equal "GET", FakeWeb.last_request.method
    assert_equal Endpoint.all.length, assigns[:endpoint_server_statuses].size
    assert_equal 'good', assigns[:endpoint_server_statuses][Endpoint.all[0].id][:backend_status]
  end
  
  test "should gracefully refresh downed endpoint status" do
    Endpoint.all.each do |endpoint|
      endpoint.base_url = HTTP_PROTO_CLIENT+"://something.totally.invalid:9999"
      endpoint.save!
    end
    get :refresh_endpoint_statuses
    assert_equal Endpoint.all.length, assigns[:endpoint_server_statuses].size
    assert_equal 'unreachable', assigns[:endpoint_server_statuses][Endpoint.all[0].id][:backend_status]
  end
  
end
