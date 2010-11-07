require 'test_helper'

class EmploymentStatusTest < ActiveSupport::TestCase
  # Test that code and description are both required and both checked for uniqueness
  test "code and description" do
    @a = EmploymentStatus.new(:code => 98765, :description => 'xhkselxhjehbbe')
    assert_and_desc_ok(@a)
  end
end
