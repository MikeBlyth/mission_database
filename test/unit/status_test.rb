require 'test_helper'

class StatusTest < ActiveSupport::TestCase
  # Test that code and description are both required and both checked for uniqueness
  test "code and description" do
    @a = Status.new(:code => 98765, :description => 'xhkselxhjehbbe')
    assert_and_desc_ok(@a)
  end
end
