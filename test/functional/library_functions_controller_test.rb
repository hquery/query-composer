require 'test_helper'
include Devise::TestHelpers

class LibraryFunctionsControllerTest < ActionController::TestCase
  setup do
    
    dump_database
    @user = Factory(:user_with_library_functions)
    @another_user = Factory(:user_with_library_functions)
    @admin = Factory(:admin)
    
    @library_function = @user.library_functions[0]
    @library_function_unsaved = Factory.build(:library_function)
    
    sign_in @user

  end

  test "should get index as user" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:library_functions)
    library_functions = assigns(:library_functions)
    assert_equal @user.library_functions.count, library_functions.count
    assert_equal @user.library_functions, library_functions
    
  end

  test "should get index as admin" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil assigns(:library_functions)
    assert_equal LibraryFunction.all, assigns(:library_functions)
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create library_function" do
    sign_in @user
    assert_difference('LibraryFunction.count') do
      post :create, library_function: @library_function_unsaved.attributes
    end

    assert_redirected_to library_function_path(assigns(:library_function))
  end

  test "should not create library function without required fields" do
    sign_in @user
    # make sure that base_url is required
    post :create, library_function: {name: "blah"}
    invalid_function = assigns[:library_function]
    assert_not_nil invalid_function
    assert !invalid_function.valid?
    assert invalid_function.errors[:name].empty?
    assert !invalid_function.errors[:definition].empty?
    assert_response :success
  end

  test "function name should be required" do
    sign_in @user
    #make sure that name is also required
    post :create, library_function: {definition: "blah"}
    invalid_function = assigns[:library_function]
    assert !invalid_function.valid?
    assert !invalid_function.errors[:name].empty?
    assert invalid_function.errors[:definition].empty?
    assert_response :success
  end
  
  test "should show library_function" do
    sign_in @user
    get :show, id: @library_function.id
    assert_equal @library_function, assigns[:library_function]
    assert_response :success
  end

  test "should not show unowned library function" do
    sign_in @user
    get :show, id: @another_user.library_functions[0].id
    assert_response :redirect
  end

  test "should show unowned library function if admin" do
    sign_in @admin
    get :show, id: @library_function.id
    assert_equal @library_function, assigns[:library_function]
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @library_function.id
    assert_response :success
  end

  test "should update library_function" do
    sign_in @user
    put :update, id: @library_function.id, library_function: @library_function.attributes
    assert_redirected_to library_function_path(assigns(:library_function))
  end
  
  test "should not update library function if invalid" do
    # make sure we can't update to be invalid
    put :update, id: @library_function.to_param, library_function: {definition: nil}
    invalid_function = assigns[:library_function]
    assert_not_nil invalid_function
    assert !invalid_function.valid?
    assert invalid_function.errors[:name].empty?
    assert !invalid_function.errors[:definition].empty?
    assert_response :success

  end
  test "should destroy library_function" do
    sign_in @user
    assert_difference('LibraryFunction.count', -1) do
      delete :destroy, id: @library_function.to_param
    end

    assert_redirected_to library_functions_path
  end
  
end
