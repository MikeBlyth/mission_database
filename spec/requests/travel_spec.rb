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
        fill_in "record[other_travelers]", :with => 'Santa Claus'
        click_button "Create"
      end.should change(Travel, :count).by(1)
    end      

    it "stores all the input correctly" do
      member = Factory(:member)
      visit new_travel_path
      select(member.last_name)
      fill_in "record[other_travelers]", :with => 'Santa Claus'
      check "With spouse"
      check "With children"
      fill_in "Total passengers", :with => '7'
      fill_in "Date", :with => '2020-01-01'
      fill_in "Time", :with => '5:17pm'
      fill_in "Return date", :with => '2020-02-01'
      fill_in "Return time", :with => '4:43am'
      fill_in "Origin", :with => 'Paris'
      fill_in "Destination", :with => "Moscow"
      fill_in "Flight", :with => "Air Zimbabwe"
      check "Personal"
      fill_in "Optional description", :with => 'Getting away'
      check "Will make own arrangements"
      fill_in "Guesthouse", :with => 'Hilton'
      fill_in "Driver accom", :with => 'Sheraton'
      fill_in "Baggage", :with => '26'
      fill_in "Date confirmed", :with => '2019-01-01'
      fill_in "Comments", :with => 'Have a nice trip!'
      click_button "Create"
      
      # Check stored values
      t = Travel.first  # Trip
      r = Travel.last   # Return trip
      # Values common to each
      [t, r].each do |x|
        x.member.should == member
        x.other_travelers.should == 'Santa Claus'
        x.with_spouse.should be_true
        x.with_children.should be_true
        x.total_passengers.should == 7
        x.flight.should == "Air Zimbabwe"
        x.personal.should == true
        x.term_passage.should == false
        x.ministry_related.should == false
        x.purpose.should == 'Getting away'
      end  
      # Values differing between original and return flight
      t.date.should == Date.new(2020,01,01)
      t.time.strftime("%R").should =~ /17:17/
      t.return_date.should == Date.new(2020,02,01)
      t.return_time.strftime("%R").should =~ /04:43/
      r.date.should == Date.new(2020,02,01)
      r.time.strftime("%R").should =~ /04:43/
      r.return_date.should == nil
      r.return_time.should == nil

      t.origin.should == 'Paris'
      t.destination.should == 'Moscow'
      r.origin.should == 'Moscow'
      r.destination.should == 'Paris'
      t.arrival.should == false
      r.arrival.should == true      
      t.own_arrangements.should == true
      r.own_arrangements.should == false
      t.guesthouse.should == 'Hilton'
      t.driver_accom.should == 'Sheraton'
      r.guesthouse.should == nil
      r.driver_accom.should == nil
      t.baggage.should == 26
      r.baggage.should == nil
      t.confirmed.should == Date.new(2019,1,1)
      r.confirmed.should == nil
      t.comments.should == 'Have a nice trip!'
      r.comments.should == nil
    end   # Checking all values stored
      
  end
end
