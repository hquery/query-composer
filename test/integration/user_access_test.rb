require 'test_helper'
include Devise::TestHelpers

class UserAccessTest < ActionDispatch::IntegrationTest

  setup do
    dump_database

    @admin = FactoryGirl.create(:admin)
    @user = FactoryGirl.create(:user_with_queries)
    
    @new_endpoint = FactoryGirl.create(:endpoint)
    @unattached_query = FactoryGirl.create(:query)
    
  end

  test "login should be required to access anything" do
    get "/"
    assert_response :redirect
    assert_equal path, '/unauthenticated'
    
    get "/queries"
    assert_response :redirect
    assert_equal path, '/unauthenticated'

    get "/endpoints"
    assert_response :redirect
    assert_equal path, '/unauthenticated'

    # make sure the sign in page comes up fine
    get "/users/sign_in"
    assert_response :success
    
  end

  test "non admin user should not be able to access the admin pages" do
    login @user

    get "/admin/users"
    assert_response :redirect
  end

  test "admin user should not be able to access the admin pages" do
    login @admin

    get "/admin/users"
    assert_response :success
  end

  test "user should not be able to access queries they do not own" do
    login @user

    get "/queries/#{@unattached_query.id}"
    assert_response :redirect
  end

  test "unapproved user should not be able to access anything" do
    
    @user.approved = false;
    @user.save!
    
    login @user

    get "/queries"
    assert_redirected_to user_session_path
  end

  test "disabled user should not be able to access anything" do
    
    @user.disabled = true;
    @user.save!
    
    login @user

    get "/queries"
    assert_redirected_to user_session_path
  end


  test "admin should be able to access queries they do not own" do
    login @admin

    get "/queries/#{@unattached_query.id}"
    assert_response :success
  end

  test "users should not be able to edit endpoints" do
    login @user
    put "/endpoints/#{@new_endpoint.id}", 'endpoint[name]' => 'new name', 'endpoint[base_url]' => 'http://example.com/'
    assert_response :redirect
    endpoint_updated = Endpoint.find(@new_endpoint.id);
    assert_equal @new_endpoint.id, endpoint_updated.id
    assert_equal @new_endpoint.name, endpoint_updated.name
    assert_equal @new_endpoint.submit_url, endpoint_updated.submit_url
  end

  test "admin should be able to edit endpoints" do
    login @admin
    put "/endpoints/#{@new_endpoint.id}", 'endpoint[name]' => 'new name', 'endpoint[base_url]' => 'http://example.com/'
    assert_response :redirect
    endpoint_updated = Endpoint.find(@new_endpoint.id)
    assert_equal @new_endpoint.id, endpoint_updated.id
    assert_equal 'new name', endpoint_updated.name
    assert_equal 'http://example.com/queries', endpoint_updated.submit_url.to_s
  end

  def login(user)
    post_via_redirect user_session_path, 'user[username]' => user.username, 'user[password]' => user.password
  end

end
