require 'test_helper'
include Devise::TestHelpers

class QueriesControllerTest < ActionController::TestCase
  
  setup  do 
    
    dump_database
    
    @user = Factory(:user_with_queries)
    @ids = @user.queries.order_by([[:created_at, :desc]]).map {|q| q.id}
    @user_ids = [] << @user.id
    
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
    assert_response :success
  end

  test "should get edit with generated query" do
    sign_in @user
    query = Query.find(@ids[0])
    query.generated = true
    query.init_query_structure!
    query.save!
    
    get :edit, id: @ids[0]
    cloned_query = assigns(:query)
    assert !cloned_query.generated?
    assert_not_equal @ids[0], cloned_query.id
    assert_equal "#{query.title} (cloned)", cloned_query.title
    assert_equal query.map, cloned_query.map
    assert_response :success
  end

  test "should get builder" do
    sign_in @user
    get :builder, id: @ids[0]
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
