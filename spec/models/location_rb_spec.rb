describe Location do
  include SimTestHelper
  include LocationHelper

  it "makes a nice selection list from locations" do
    setup_cities
    setup_locations
    # The tests are dependent on the test data used. They expect the exact options shown and in the exact order, so
    # any changes to the test data will likely break the tests.
    choices = location_choices(2).gsub(/\n/, '')  # Rails procedure throws in random line-breaks; remove for testing
    choices.should =~ /^<option value=''><\/option><optgroup label="Abuja"><option value="9">Abuja Guest House<\/option>/
    choices.should =~ /<optgroup label="Unspecified"><option value="999999">Unspecified<\/option><\/optgroup>$/
    choices.should =~ /<optgroup label="Jos"><option value="2" selected="selected">ECWA<\/option><option value="1">Evangel<\/option>/
  end

  describe "check before destroy:" do

    before(:each) do
      @location = Factory(:location)
      @family = Factory(:family)
      @member = Factory(:member, :family=>@family)
      @family.update_attribute(:head, @member)
    end
    
    it "does destroy if there are no existing linked records" do
      lambda do
        @location.destroy
      end.should change(Location, :count).by(-1)
    end
    

    it "does not destroy if there is existing family" do
      @family.update_attribute(:residence_location, @location)
      @family.head.update_attribute(:residence_location, nil)
      lambda do
        @location.destroy
      end.should_not change(Location, :count)
    end
      
    it "does not destroy if there is existing member w residence" do
      @family.head.update_attribute(:residence_location, @location)
      lambda do
        @location.destroy
      end.should_not change(Location, :count)
    end
      
    it "does not destroy if there is existing member w work location" do
      @family.head.update_attribute(:work_location, @location)
      lambda do
        @location.destroy
      end.should_not change(Location, :count)
    end
      
    it "does not destroy if there is existing field_term w work location" do
      f = Factory(:field_term, :primary_work_location => @location)
      lambda do
        @location.destroy
      end.should_not change(Location, :count)
    end
      
  end # check before destroy
      
end

