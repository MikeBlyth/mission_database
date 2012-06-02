require 'spec_helper'

describe "locations/edit" do
  before(:each) do
    @location = assign(:location, stub_model(Location,
      :name => "MyString",
      :state => "MyString",
      :city => "MyString",
      :lga => "MyString",
      :gps_latitude => "",
      :gps_longitude => ""
    ))
  end

  it "renders the edit location form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => locations_path(@location), :method => "post" do
      assert_select "input#location_name", :name => "location[name]"
      assert_select "input#location_state", :name => "location[state]"
      assert_select "input#location_city", :name => "location[city]"
      assert_select "input#location_lga", :name => "location[lga]"
      assert_select "input#location_gps_latitude", :name => "location[gps_latitude]"
      assert_select "input#location_gps_longitude", :name => "location[gps_longitude]"
    end
  end
end
