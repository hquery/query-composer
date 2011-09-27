require 'test_helper'
require 'result_presenter'
require 'generated_result_presenter'

class GeneratedResultPresenterTest < ActionController::TestCase
  test "properly format javascript arrays for values" do
    p = GeneratedResultPresenter.new('foo', {'M' => {'age' => {'mean' => 2}},
                                             'F' => {'age' => {'mean' => 2}}})
    assert_equal '[[2,2]]', p.value_javascript_array
  end
  
  test "properly format javascript arrays for keys" do
    p = GeneratedResultPresenter.new('foo', {'M' => {'age' => {'mean' => 2}},
                                             'F' => {'age' => {'mean' => 2}}})
    assert_equal '["age_mean"]', p.key_javascript_array
  end
end