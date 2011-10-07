require 'test_helper'
require 'result_presenter'
require 'generated_result_presenter'

class GeneratedResultPresenterTest < ActionController::TestCase
  test "properly format javascript arrays for values" do
    p = GeneratedResultPresenter.new('foo', {'Results' => {'gender' => {'frequency' => {'M' => 2, 'F' => 3}}}})
    assert_equal '[2,3]', p.value_javascript_array
  end
  
  test "properly format javascript arrays for keys" do
    p = GeneratedResultPresenter.new('foo', {'Results' => {'gender' => {'frequency' => {'M' => 2, 'F' => 3}}}})
    assert_equal '["M","F"]', p.key_javascript_array
  end
end