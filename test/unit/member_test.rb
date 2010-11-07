require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  # Test that city_id is required
  test "required fields" do
    @a = Member.new(:last_name=>'A',:first_name=>'b', :sex=>'m', :family_id=>1)
    assert_presence_required(@a, :last_name)
    assert_presence_required(@a, :first_name)
    
  end    
end
