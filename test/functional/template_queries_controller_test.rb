require 'test_helper'
include Devise::TestHelpers

class TemplateQueriesControllerTest < ActionController::TestCase
  setup do
    dump_database
    @template_query = Factory(:template_query)
    @unsaved_template_query = Factory.build(:template_query)
    @admin = Factory(:admin)
    sign_in @admin
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:template_queries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create template_query" do
    assert_difference('TemplateQuery.count') do
      post :create, template_query: @unsaved_template_query.attributes
    end

    assert_redirected_to template_queries_url
  end


  test "should get edit" do
    get :modify, id: @template_query.to_param
    assert_response :success
  end

  test "should update template_query" do
    put :modup, id: @template_query.to_param, template_query: @template_query.attributes
    assert_redirected_to template_queries_url
  end

  test "should destroy template_query" do
    assert_difference('TemplateQuery.count', -1) do
      delete :destroy, id: @template_query.to_param
    end

    assert_redirected_to template_queries_path
  end
end
