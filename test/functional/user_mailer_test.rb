require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do 
    dump_database
    
    @user = FactoryGirl.create(:user_with_queries)
    @ids = @user.queries.map {|q| q.id}
  end
  
  test "should deliver execution notification e-mails" do
    query = Query.find(@ids[4]) 
    mail = UserMailer.execution_notification(query.last_execution)
    assert_equal "[hQuery] Results for #{query.title}", mail.subject
    assert_equal ["#{@user.email}"], mail.to
    assert_equal ["hQueryMcNoreply@mitre.org"], mail.from
    assert_match "Your query called \"#{query.title}\" just finished up.", mail.body.encoded
  end
end
