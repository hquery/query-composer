require 'test_helper'
include Devise::TestHelpers

class EndpointsControllerTest < ActionController::TestCase
  setup do
    dump_database
    
    @admin = Factory(:admin)
    
    @endpoint = Factory(:endpoint)
    @endpoint_unsaved = Factory.build(:endpoint)
    
    sign_in @admin
    
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

  test "should destroy endpoint" do
    assert_difference('Endpoint.count', -1) do
      delete :destroy, id: @endpoint.to_param
    end

    assert_redirected_to endpoints_path
  end
end
