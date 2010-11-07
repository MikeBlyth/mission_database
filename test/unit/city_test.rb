require 'test_helper'

class CityTest < ActiveSupport::TestCase

  setup do
    @city = City.new(:name=>'Kano', :state=>'Kano', :country=>'Nigeria')
  end

  test "name" do
    assert_presence_required(@city, :name)
    assert_presence_required(@city, :country)
    assert_presence_required(@city, :state)  # While country is Nigeria, from setup
  end

  test "missing state error msg" do
    @city.state = ''
    @city.valid?
    # Check that error message for missing state includes the word "Nigeria", 
    # This would of course be changed if we require state for all countries or for none
    assert(@city.errors[:state].to_s =~ /Nigeria/)
  end
  
  test 'presence of state' do
    @city.country='US' 
    @city.state=''
    assert(@city.valid?,"State should not be required if country is not Nigeria")
  end
  
end
