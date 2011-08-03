require 'test_helper'

class TemplateQueriesControllerTest < ActionController::TestCase
  setup do
    @template_query = template_queries(:one)
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
      post :create, template_query: @template_query.attributes
    end

    assert_redirected_to template_query_path(assigns(:template_query))
  end


  test "should get edit" do
    get :modify, id: @template_query.to_param
    assert_response :success
  end

  test "should update template_query" do
    put :modup, id: @template_query.to_param, template_query: @template_query.attributes
    assert_redirected_to template_query_path(assigns(:template_query))
  end

  test "should destroy template_query" do
    assert_difference('TemplateQuery.count', -1) do
      delete :destroy, id: @template_query.to_param
    end

    assert_redirected_to template_queries_path
  end
end
