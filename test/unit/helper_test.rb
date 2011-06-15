require 'test_helper'

class HelperTest < ActiveSupport::TestCase

  setup do
  end

  include QueriesHelper
  
  test 'JSONification' do
    assert jsonify(10)==10
    assert jsonify('hello')=='hello'
    json = jsonify({'a' => 'b'})
    assert json.class==String
    expected_json="{\n  \"a\": \"b\"\n}"
    assert json==expected_json
  end
end