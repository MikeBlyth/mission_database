require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  # Test that code and description are both required and both checked for uniqueness
  test "code and description" do
    @a = Location.new(:code => 98765, :description => 'xhkselxhjehbbe', :city_id => 1)
    assert_and_desc_ok(@a)
  end

  # Test that city_id is required
  test "city_id required" do
    @a = Location.new(:code => 98765, :description => 'xhkselxhjehbbe', :city_id => 1)
    assert_presence_required(@a, :city_id)
  end    
  # Test that city_id has existing parent (referant)
  test "city_id matches a city" do
    @a = Location.new(:code => 98765, :description => 'xhkselxhjehbbe', :city_id => 1)
    assert_parent_required(@a, :city_id, 9953)
  end    
end
