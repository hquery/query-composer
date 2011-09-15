require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  setup do
    
    dump_database
    
    user = Factory(:user_with_queries)
    @user_ids = [] << user.id
    @ids = user.queries.map {|q| q.id}

    @ids_not_owned = [] << Factory(:query).id
    @ids_not_owned << Factory(:query).id
    @ids_not_owned << Factory(:query).id
    
  end
  
  test "user queries returned" do
    
    user = User.find(@user_ids[0])
    assert_not_nil user
    assert_equal 6, user.queries.length
    
    user.queries.each do |query|
      assert @ids.include?(query.id)
      assert not(@ids_not_owned.include?(query.id))
    end
    
    assert_equal 9, Query.all.length
    
  end
  
  test "user should be found by username" do
    user = User.find(@user_ids[0])
    found_user = User.find_by_username user.username
    assert_equal user, found_user
  end
  
  test "user should be found by email" do
    user = User.find(@user_ids[0])
    found_user = User.find_by_email user.email
    assert_equal user, found_user
  end
  
  
end
