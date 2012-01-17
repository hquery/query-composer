require 'test_helper'
include Devise::TestHelpers

class UserAccessTest < ActionDispatch::IntegrationTest

  setup do
    dump_database

    @admin = Factory(:admin)
    @user = Factory(:user_with_queries)
    
    @unattached_query = Factory(:query)
    
  end

  test "login should be required to access anything" do
    get "/"
    assert_response :redirect
    assert_equal path, '/unauthenticated'
    
    get "/queries"
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

  def login(user)
    post_via_redirect user_session_path, 'user[username]' => user.username, 'user[password]' => user.password
  end

end
