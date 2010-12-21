require 'spec_helper'
require 'application_helper'

describe Location do
  it "makes a nice selection list" do
    locations = [ {:city=>'Jos', :description=>'Evangel', :id=>1},
                  {:city=>'Jos', :description=>'ECWA', :id=>2},
                  {:city=>'Jos', :description=>'JETS', :id=>3},
                  {:city=>'Miango', :description=>'MRH', :id=>4},
                  {:city=>'Miango', :description=>'KA', :id=>5},
                  {:city=>'Miango', :description=>'Miango Dental Clinic', :id=>6},
                  {:city=>'Kano', :description=>'Tofa Bible School', :id=>7},
                  {:city=>'Kano', :description=>'Kano Eye Hospital', :id=>8},
                  {:city=>'Abuja', :description=>'Abuja Guest House', :id=>9}]
#    cities = [ {:id=>1, :name=>'Jos'}, {:id=>2, :name=>'Miango'}, {:id=>3, :name=>'Kano'}]
    choices = options_for_select_with_grouping(locations, :city)
    choices[0].should == "<optgroup label='Abuja'>"
    choices[1].should == "<option value='9'>Abuja Guest House<\/option>"
    choices[2].should == "<optgroup label='Jos'>"
    choices[3].should == "<option value='2'>ECWA<\/option>"
    choices[4].should == "<option value='1'>Evangel<\/option>"
puts choices
  end
end

