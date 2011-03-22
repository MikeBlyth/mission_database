require 'spec_helper'

describe "Travels" do

  describe "By administrator" do
  
    before(:each) { integration_test_sign_in(:admin=>true)}

    it "should add a travel record for an existing member" do
      lambda do
        member = Factory(:member)
        visit new_travel_path
        fill_in "Date", :with => '2020-01-01'
        select(member.last_name)
        click_button "Create"
      end.should change(Travel, :count).by(1)
    end      

    it "should add a travel record for a guest" do
      lambda do
        member = Factory(:member)
        visit new_travel_path
        fill_in "Date", :with => '2020-01-01'
        fill_in "Other travelers", :with => 'Santa Claus'
        click_button "Create"
      end.should change(Travel, :count).by(1)
    end      

  end
end
