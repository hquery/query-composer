require 'test_helper'

class ResultTest < ActiveSupport::TestCase
  setup do
    dump_database
  end

  test "check a result that has changed" do
    FakeWeb.register_uri(:get, "https://localhost:3000/queries/4e4c08b5431a5f5dc1000001",
                         :body => '{"status": "'+Result::COMPLETE+'", "result_url": "https://localhost/results/1234"}')
    FakeWeb.register_uri(:get, "https://localhost/results/1234",
                         :body => '{"foo": "bar"}')

    result = FactoryGirl.create(:result_waiting)
    result_updated_at = result.updated_at
    result.check
    result.reload
    assert_equal Result::COMPLETE, result.status
    assert_equal 'bar', result.value['foo']
    assert result_updated_at != result.updated_at
  end
  
  test "fetch a result" do
    FakeWeb.register_uri(:get, "https://localhost/results/1234",
                         :body => '{"foo": "bar"}')
    result = FactoryGirl.create(:result, :result_url => "https://localhost/results/1234")
    result.fetch_result
    assert_equal Result::COMPLETE, result.status
    assert_equal 'bar', result.value['foo']
  end
  
  test "checking a result" do
    FakeWeb.register_uri(:get, "https://localhost:3000/queries/4e4c08b5431a5f5dc1000001",
                         :body => '{"status": "complete", "result_url": "https://localhost/results/1234"}')
    FakeWeb.register_uri(:get, "https://localhost/results/1234",
                         :body => '{"foo": "bar", "status": "complete"}')
    result = FactoryGirl.create(:result_waiting)
    result.check
    assert_equal Result::COMPLETE, result.status
    assert_equal 'bar', result.value['foo']
  end
  
  test "checking a result where there is an error" do
    FakeWeb.register_uri(:get, "https://localhost:3000/queries/4e4c08b5431a5f5dc1000001",
                         :body => '{"status": "failed", "error_message": "game over, man!"}')
    result = FactoryGirl.create(:result_waiting)
    result.check
    assert_equal Result::FAILED, result.status
    assert_equal 'game over, man!', result.error_msg
  end
end