require 'spec_helper'
require 'application_helper'
require 'sim_test_helper'

describe Location do

  def setup_locations_hash
    @locations_hash = [ {:city=>'Jos', :city_id => 2, :description=>'Evangel', :id=>1},
                  {:city=>'Jos', :city_id => 2, :description=>'JETS', :id=>3},
                  {:city=>'Jos', :city_id => 2, :description=>'ECWA', :id=>2},
                  {:city=>'Miango', :city_id => 4, :description=>'MRH', :id=>4},
                  {:city=>'Miango', :city_id => 2, :description=>'KA', :id=>5},
                  {:city=>'Miango', :city_id => 2, :description=>'Miango Dental Clinic', :id=>6},
                  {:city=>'Kano', :city_id => 3, :description=>'Tofa Bible School', :id=>7},
                  {:city=>'Kano', :city_id => 3, :description=>'Kano Eye Hospital', :id=>8},
                  {:city=>'Abuja', :city_id => 5, :description=>'Abuja Guest House', :id=>9}]
  end
  
  def setup_cities
    Factory.create(:city, :name => 'Jos', :id=>2)
    Factory.create(:city, :name => 'Kano', :id=>3)
    Factory.create(:city, :name => 'Miango', :id=>4)
    Factory.create(:city, :name => 'Abuja', :id=>5)
    Factory.create(:city_unspecified)
  end

  def setup_locations
    setup_locations_hash
    @locations_hash.each do |location| 
      Factory.create(:location, :id=>location[:id], :city_id=>location[:city_id],
              :description=>location[:description])
#puts "Created #{f.description}"
    end
    Factory.create(:location_unspecified)
    @locations = Location.all
  end
    
## Obsolete -- uses our own function options_for_select_with_grouping rather than Rails' 
##    option_groups_from_collection_for_select
#  it "makes a nice selection list" do
#    setup_locations_hash
#    choices = options_for_select_with_grouping(@locations_hash, :city, 2)
#    choices[0].should == "<optgroup label='Abuja'>"
#    choices[1].should == "<option value='9'>Abuja Guest House<\/option>"
#    choices[2].should == "<optgroup label='Jos'>"
#    choices[3].should == "<option value='2' selected='selected'>ECWA</option>"
#    choices[4].should == "<option value='1'>Evangel<\/option>"
#  end


  it "makes a nice selection list from locations" do
    setup_cities
    setup_locations
    # The tests are dependent on the test data used. They expect the exact options shown and in the exact order, so
    # any changes to the test data will likely break the tests.
    choices = location_selection_list(2).gsub(/\n/, '')  # Rails procedure throws in random line-breaks; remove for testing
    choices.should =~ /^<optgroup label="Abuja"><option value="9">Abuja Guest House<\/option>/
    choices.should =~ /<optgroup label="Unspecified"><option value="-1">Unspecified<\/option><\/optgroup>$/
    choices.should =~ /<optgroup label="Jos"><option value="2" selected="selected">ECWA<\/option><option value="1">Evangel<\/option>/

  end
end

