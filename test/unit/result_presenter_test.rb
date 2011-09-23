require 'test_helper'
require 'result_presenter'

class ResultPresenterTest < ActionController::TestCase
  test "knows when it is empty" do
    p = ResultPresenter.new('foo', nil)
    assert ! p.exist?
  end
  
  test "properly filters keys" do
    p = ResultPresenter.new('foo', '_id' => 1234, 'M' => 2, 'F' => 2)
    assert ! p.keys.include?('_id')
    assert p.keys.include?('M')
  end
  
  test "properly filters values" do
    p = ResultPresenter.new('foo', '_id' => 1234, 'M' => 2, 'F' => 2)
    assert ! p.values.include?(1234)
    assert p.values.include?(2)
  end
  
  test "properly format javascript arrays for values" do
    p = ResultPresenter.new('foo', '_id' => 1234, 'M' => 2, 'F' => 2)
    assert_equal '[2, 2]', p.value_javascript_array
  end
  
  test "properly format javascript arrays for keys" do
    p = ResultPresenter.new('foo', '_id' => 1234, 'M' => 2, 'F' => 2)
    assert_equal '["M", "F"]', p.key_javascript_array
  end
end