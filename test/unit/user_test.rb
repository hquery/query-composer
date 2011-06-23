require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  setup do
    @user_ids = setup_users()
    @user = User.find(@user_ids[0])
    @ids = collection_fixtures('queries', @user)
    @ids_not_owned = collection_fixtures('queries', nil, false)
  end
  
  test "user queries returned" do
    
    user = User.find(@user_ids[0])
    assert_not_nil user
    assert_equal 3, user.queries.length
    
    user.queries.each do |query|
      assert @ids.include?(query.id)
      assert not(@ids_not_owned.include?(query.id))
    end
    
    assert_equal 6, Query.all.length
    
  end
end
