require 'test_helper'

class MinistryTest < ActiveSupport::TestCase
  # Test that code and description are both required and both checked for uniqueness
  test "code and description" do
    @a = Ministry.new(:code => 98765, :description => 'xhkselxhjehbbe')
    assert_and_desc_ok(@a)
  end
end
