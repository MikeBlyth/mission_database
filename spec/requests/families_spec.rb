require 'spec_helper'
require 'sim_test_helper'

describe "Families" do
include SimTestHelper

  describe "by admin" do

    before(:each) do
      integration_test_sign_in(:admin=>true)
      @family = Factory(:family)
      seed_tables
    end  

#    it 'avoids "ambiguous status_id" bug' do
#      visit families_path
#      click_link "Active only"
#    end

    it "editing family should change all values correctly" do
      @family = factory_family_full :couple=>true, :child=>true
      birth_date = Date.new(2000,1,1)
      temp_loc_from = Date.new(2011,1,1)
      temp_loc_until = Date.new(2011,1,10)
      date_active = Date.new(2000,2,1)
      field_term_start = Date.new(2000,4,4)
      field_term_end = Date.new(2004,4,4)
      est_field_term_start = Date.new(2000,5,4)
      est_field_term_end = Date.new(2004,5,4)
      visit edit_family_path(@family)
      within("#tabs-head") do
        fill_in "First name", :with => "Samuel"
        fill_in "Middle name", :with => "Jonah"
        fill_in "Short name", :with => "Sam"
        select 'Male', :from=>'Sex'
        fill_in "Birth date", :with => birth_date.strftime("%F")
        select "Afg", :from=>'Country'
        select "Educ"
        fill_in "Qualifications", :with=> "Very qualified"

        fill_in "Full name", :with=>"Newman, Alfred E."
        fill_in "Date active", :with => date_active.strftime("%F")
        fill_in "Est. end of service", :with => (date_active+365.days).strftime("%F")
        select 'Career'
        select 'Ministry'
        select 'Site', :from=>'Ministry location'
        fill_in 'Ministry comment', :with=> "ministry comment"
        fill_in 'Temporary location', :with=> "out of town"
        fill_in "head_temporary_location_from_date", :with => temp_loc_from.strftime("%F")
        fill_in "head_temporary_location_until_date", :with => temp_loc_until.strftime("%F")
      end # Within head tab

      click_button "Update"

      m = @family.head.reload
      m.first_name.should == 'Samuel'
      m.middle_name.should == 'Jonah'
      m.short_name.should == 'Sam'
      m.sex.should == 'M'
      m.birth_date.should == birth_date
      m.country.name.should =~ /Afghanistan/
      m.personnel_data.education.description.should =~ /Educ/
      m.personnel_data.qualifications.should == "Very qualified"
      m.name.should == "Newman, Alfred E."
      m.personnel_data.date_active.should == date_active
      m.personnel_data.est_end_of_service.should == date_active+365.days
      m.ministry.description.should =~ /Min/
      m.ministry_comment.should ==   "ministry comment"    
      m.residence_location.description.should =~ /Site/
      m.work_location.description.should  =~ /Site/
      m.temporary_location.should == 'out of town'
      m.temporary_location_from_date.should == temp_loc_from
      m.temporary_location_until_date.should == temp_loc_until
      m.personnel_data.employment_status.description.should =~ /Career/
    end # editing family should change all values correctly

  end # describe by Admin
end # describe Families
