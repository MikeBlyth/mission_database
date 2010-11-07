require 'test_helper'

class EducationTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  test "code and description" do
    @ed = Education.new(:code => 98765, :description => 'xhkselxhjehbbe')
    assert_and_desc_ok(@ed)
  end
end
