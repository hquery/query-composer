require 'test_helper'
include Devise::TestHelpers

class AdminControllerTest < ActionController::TestCase
  
  setup  do 
    
    dump_database
    
    @admin = Factory(:admin)
    @user = Factory(:user)
    @user2 = Factory(:user)
    @unapproved_user = Factory(:unapproved_user)

    @admin2 = Factory(:admin)

    @user_ids = [] << @user.id
    
  end
  
  test "should get user list if admin" do
    sign_in @admin
    get :users
    users = assigns[:users]
    assert_not_nil users
    assert_response :success
  end

  test "should not get user list if not admin" do
    sign_in @user
    get :users
    users = assigns[:users]
    assert_nil users
    assert_response :redirect
  end

  test "promote user should make user admin" do
    sign_in @admin
    assert !@user.admin?
    post :promote, username: @user.username
    @user = User.find(@user.id)
    assert @user.admin?
    assert_response :success
  end

  test "demote user should make user not admin" do
    sign_in @admin
    assert @admin2.admin?
    post :demote, username: @admin2.username
    @admin2 = User.find(@admin2.id)
    assert !@admin2.admin?
    assert_response :success
  end

  test "should not be able to promote if not admin" do
    sign_in @user
    assert !@user.admin?
    post :promote, username: @user.username
    @user = User.find(@user.id)
    assert !@user.admin?
    assert_response :redirect
  end

  test "should not be able to demote if not admin" do
    sign_in @user
    assert @admin2.admin?
    post :demote, username: @admin2.username
    @admin2 = User.find(@admin2.id)
    assert @admin2.admin?
    assert_response :redirect
  end

  test "delete user should remove the user" do
    sign_in @admin
    post :destroy, username: @user2.username
    assert (not User.exists? :conditions => {id: @user2.id})
    assert_response :success
  end
  
  test "delete user should not remove the user if not admin" do
    sign_in @user
    post :destroy, username: @user2.username
    assert (User.exists? :conditions => {id: @user2.id})
    assert_response :redirect
  end

  test "approve user should approve the user" do
    sign_in @admin
    assert !@unapproved_user.approved?
    post :approve, username: @unapproved_user.username
    @unapproved_user = User.find(@unapproved_user.id)
    assert @unapproved_user.approved?
    assert_response :success
  end

  test "approve user should not approve the user if not admin" do
    sign_in @user
    assert !@unapproved_user.approved?
    post :approve, username: @unapproved_user.username
    @unapproved_user = User.find(@unapproved_user.id)
    assert !@unapproved_user.approved?
    assert_response :redirect
  end


  test "delete invalid user should not freak out" do
    sign_in @admin
    post :destroy, username: "crapusername"
    assert_response :success
  end

  test "promote invalid user should not freak out" do
    sign_in @admin
    post :promote, username: "crapusername"
    assert_response :success
  end

  test "approve invalid user should not freak out" do
    sign_in @admin
    post :approve, username: "crapusername"
    assert_response :success
  end
  
end
