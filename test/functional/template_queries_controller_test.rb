require 'test_helper'
include Devise::TestHelpers

class TemplateQueriesControllerTest < ActionController::TestCase
  setup do
    
    dump_database
    @user = FactoryGirl.create(:user)
    @admin = FactoryGirl.create(:admin)
    
    @template_query = FactoryGirl.create(:template_query)
    @template_query_unsaved = FactoryGirl.build(:template_query)

  end

  test "should get index as user" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:template_queries)

    # TODO This fails because the _type field is added to the database by
    # default starting in Mongoid 3.0 (it wasn't previously)
    # See https://github.com/mongoid/mongoid/issues/936
    #assert_equal TemplateQuery.all, assigns(:template_queries)
  end

  test "should get index as admin" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:template_queries)

    # TODO This fails because the _type field is added to the database by
    # default starting in Mongoid 3.0 (it wasn't previously)
    # See https://github.com/mongoid/mongoid/issues/936
    #assert_equal TemplateQuery.all, assigns(:template_queries)
  end

  test "should get new" do
    sign_in @admin
    get :new
    assert_response :success
  end

  test "should create template query" do
    sign_in @admin
    assert_difference('TemplateQuery.count') do
      post :create, template_query: @template_query_unsaved.attributes
    end

    assert_redirected_to template_query_path(assigns(:template_query))
  end

  test "should not create template query without required fields" do
    sign_in @admin
    # make sure that title
    post :create, template_query: {description: "blah"}
    invalid_template = assigns[:template_query]
    assert_not_nil invalid_template
    assert !invalid_template.valid?
    assert !invalid_template.errors[:title].empty?
    assert_response :success
  end

  test "should show template query" do
    sign_in @user
    get :show, id: @template_query.id
    assert_equal @template_query, assigns[:template_query]
    assert_response :success
  end

  test "should get edit as admin" do
    sign_in @admin
    get :edit, id: @template_query.id
    assert_response :success
  end

  test "should not get edit as user" do
    sign_in @user
    get :edit, id: @template_query.id
    assert_redirected_to root_path
  end

  test "should update template query as admin" do
    sign_in @admin
    put :update, id: @template_query.id, template_query: @template_query.attributes
    assert_redirected_to template_query_path(assigns(:template_query))
  end

  test "should not update template query as user" do
    sign_in @user
    put :update, id: @template_query.id, template_query: @template_query.attributes
    assert_redirected_to root_path
  end
  
  test "should not update library function if invalid" do
    sign_in @admin
    # make sure we can't update to be invalid
    put :update, id: @template_query.to_param, template_query: {title: nil}
    invalid_template = assigns[:template_query]
    assert_not_nil invalid_template
    assert !invalid_template.valid?
    assert !invalid_template.errors[:title].empty?
    assert_response :success
  end
  
  test "should destroy template_query as admin" do
    sign_in @admin
    assert_difference('TemplateQuery.count', -1) do
      delete :destroy, id: @template_query.to_param
    end

    assert_redirected_to template_queries_path
  end

  test "should not destroy template_query as user" do
    sign_in @user
    delete :destroy, id: @template_query.to_param
    assert_redirected_to root_path
  end
  
end
