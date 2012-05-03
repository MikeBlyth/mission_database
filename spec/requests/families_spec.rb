require 'spec_helper'
require 'sim_test_helper'

describe "Families" do
include SimTestHelper

  describe "by admin" do

    before(:each) do
      integration_test_sign_in(:admin=>true)
      @family = Factory(:family)
    end  

    it 'avoids "ambiguous status_id" bug' do
      visit families_path
      click_link "Active only"
    end

    it "editing family should change all values correctly" do
#puts "Start editing: #{Time.now}"
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
        select 'Female', :from=>'Sex'
        fill_in "Birth date", :with => birth_date.strftime("%F")
        select "Russia"
        select "Doctoral level"
        fill_in "Qualifications", :with=> "Very qualified"

        fill_in "Full name", :with=>"Newman, Alfred E."
        fill_in "Date active", :with => date_active.strftime("%F")
        fill_in "Est. end of service", :with => (date_active+365).strftime("%F")
        select 'Associate'
        select 'Surgeon'
        select '
        select 'Ministry', :from=>'record[ministry]'
        fill_in 'Ministry comment', :with=> "ministry comment"
        select 'Site', :from=>'record_residence_location'
        select 'Site', :from=>'record_work_location'
        fill_in 'Temporary location', :with=> "out of town"
        fill_in "record[temporary_location_from_date]", :with => temp_loc_from.strftime("%F")
        fill_in "record[temporary_location_until_date]", :with => temp_loc_until.strftime("%F")
        select 'Career'
        fill_in "record[personnel_data][comments]", :with => "What a lot of info to fill in."
        ft_div = "as_members-#{@head.id}-field_terms-subform-div"
      end # Within head tab
#save_and_open_page
#puts "Start update: #{Time.now}"
      click_button "Update"
#puts "End update: #{Time.now}"

      m = @head.reload
##puts "After filled in, member=#{m.attributes}"
      m.family_id.should == @new_family.id
      m.first_name.should == 'Samuel'
      m.middle_name.should == 'Jonah'
      m.short_name.should == 'Sam'
      m.sex.should == 'F'
      m.child.should == true
      m.birth_date.should == birth_date
      m.country.name.should == Country.first.name
      m.status.description.should =~ /On field/
      m.ministry.description.should =~ /Min/
      m.ministry_comment.should ==   "ministry comment"    
      m.residence_location.description.should =~ /Site/
      m.work_location.description.should  =~ /Site/
      m.temporary_location.should == 'out of town'
      m.temporary_location_from_date.should == temp_loc_from
      m.temporary_location_until_date.should == temp_loc_until
      m.health_data.current_meds.should == 'aspirin'
      m.health_data.issues.should == 'headaches'
      m.health_data.allergies.should == 'NKA'
      m.health_data.bloodtype.full.should == 'AB+'
      m.personnel_data.education.description.should =~ /Educ/
      m.personnel_data.employment_status.description.should =~ /Career/
      m.personnel_data.date_active.should == date_active
      m.personnel_data.comments.should == 'What a lot of info to fill in.'
      f = m.field_terms.first
      f.start_date.should == field_term_start
      f.end_date.should == field_term_end
      f.ministry.description.should =~ /Min/
      f.est_start_date.should == est_field_term_start
      f.est_end_date.should == est_field_term_end
      f.employment_status.description.should =~ /Career/
      f.primary_work_location.description.should  =~ /Site/
    end
    

  end
end
