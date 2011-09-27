require 'test_helper'

class CodeSetTest < ActiveSupport::TestCase

  setup do
     dump_database
   end
   
  test "Should be able to add codes to a code_set" do
    cs = Factory(:annulled_marital_status_code)
    cs.reload
    full_codes = cs.codes
    assert_equal full_codes.keys.length , 1
    codes = cs.get_code_system("MaritalStatusCodes")
    assert_equal codes.length, 1
  
    cs.add_code("MaritalStatusCodes","AA")
    codes = cs.get_code_system("MaritalStatusCodes")
    assert_equal codes.length, 2
  
  
    cs.add_code("MaritalStatusCodes2","A")
    codes = cs.get_code_system("MaritalStatusCodes2")
    assert_equal codes.length, 1
  
  end

  test "Should be able to Remove codes from a set " do
    cs = Factory(:annulled_marital_status_code)
    cs.reload
    full_codes = cs.codes
    assert_equal full_codes.keys.length , 1
    codes = cs.get_code_system("MaritalStatusCodes")
    assert_equal codes.length, 1
  
    cs.remove_code("MaritalStatusCodes", "A")
    codes = cs.get_code_system("MaritalStatusCodes")
    assert_equal codes.length, 0
  
  end

  test "Should be able to Remove all codes from a code system from a code set" do
    cs = Factory(:annulled_marital_status_code)
    cs.reload
    full_codes = cs.codes
    assert_equal full_codes.keys.length , 1
    codes = cs.get_code_system("MaritalStatusCodes")
    assert_equal codes.length, 1
  
    cs.remove_code_system("MaritalStatusCodes")
  
    codes = cs.codes
    assert_equal codes["MaritalStatusCodes"], nil
  
  end

end