require 'test_helper'

class ResultTest < ActiveSupport::TestCase
  setup do
    dump_database
  end

  test "check a result that has changed" do
    FakeWeb.register_uri(:get, "http://localhost:3000/queries/4e4c08b5431a5f5dc1000001",
                         :body => '{"status": "complete", "result_url": "http://localhost/results/1234"}')
    FakeWeb.register_uri(:get, "http://localhost/results/1234",
                         :body => '{"foo": "bar"}')

    result = Factory.create(:result_waiting)
    result_updated_at = result.updated_at
    result.check
    result.reload
    assert_equal Result::COMPLETE, result.status
    assert_equal 'bar', result.value['foo']
    assert result_updated_at != result.updated_at
  end
  
  test "fetch a result" do
    FakeWeb.register_uri(:get, "http://localhost/results/1234",
                         :body => '{"foo": "bar"}')
    result = Factory.create(:result, :result_url => "http://localhost/results/1234")
    result.fetch_result
    assert_equal Result::COMPLETE, result.status
    assert_equal 'bar', result.value['foo']
  end
end