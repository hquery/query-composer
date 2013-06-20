require 'test_helper'
include Devise::TestHelpers

class CodeSetsControllerTest < ActionController::TestCase
  
  
  setup do
    dump_database
    
    @admin = FactoryGIrl(:admin)
    
    @code_set = FactoryGIrl(:annulled_marital_status_code)
    
    sign_in @admin
    
    @user = FactoryGIrl(:user_with_queries)
    @ids = @user.queries.map {|q| q.id}
    
  end
  
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:code_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should show code set" do
    get :show, id: @code_set.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @code_set.to_param
    assert_response :success
  end

  test "should update code set" do
    put :update, id: @code_set.to_param, code_set: @code_set.attributes
    assert_redirected_to code_set_path(assigns(:code_set))
  end
  
  test "should get code sets by type" do
    get :by_type, type: "marital_status"
    assert_response :success
  end
  
  
end