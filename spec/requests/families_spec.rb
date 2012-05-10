require 'spec_helper'
require 'sim_test_helper'

describe "Families" do
include SimTestHelper

  describe "by admin" do

    before(:each) do
      integration_test_sign_in(:admin=>true)
      seed_tables
    end  

    it 'avoids "ambiguous status_id" bug' do
      visit families_path
      click_link "Active only"
    end

    it "should show error messages" do
      @family = factory_family_bare :couple=>false, :child=>false
      birth_date = Date.new(2080,1,1)
      visit edit_family_path(@family)
      fill_in "Birth date", :with => birth_date.strftime("%F")
      click_button "Update"
#      puts page.driver.body
#     puts page.find('#errorExplanation h2').to_s
      page.should have_selector('li', :content=>"Birth date can't be in future!")
      page.should have_selector('#tabs-head')  # Because we're still on edit page
    end

    it "should accept OK input without errors" do
      @family = factory_family_bare :couple=>false, :child=>false
      birth_date = Date.new(1980,1,1)
      visit edit_family_path(@family)
      fill_in "Birth date", :with => birth_date.strftime("%F")
      click_button "Update"
      page.should have_no_content "Birth date can't be in future!"
      page.should have_no_selector('#tabs-head')  # Because we're no longer on edit page
    end

    it "should catch error in children's data" do
      @family = factory_family_bare :couple=>false, :child=>true
      Factory(:employment_status, :description=>"MK dependent", :child=>true)
      birth_date = Date.new(2080,1,1)
      visit edit_family_path(@family)
      within ("#tabs-children") do
        child_id = @family.children.first.id.to_s
        fill_in "member_#{child_id}_birth_date", :with => birth_date.strftime("%F")
        select "MK dependent", :from=>"member_#{child_id}_personnel_data_employment_status_id"
      end      
      click_button "Update"
#      puts page.driver.body
#     puts page.find('#errorExplanation h2').to_s
      page.should have_selector('li', :content=>"Birth date can't be in future!")
      page.should have_selector('#tabs-head')  # Because we're still on edit page
    end

    it "should catch error in email" do
      @family = factory_family_bare :couple=>false, :child=>false
      visit edit_family_path(@family)
      fill_in "Email 1", :with=>'bad email'
      click_button "Update"
      page.should have_selector('li', :content=>"Email 1 is invalid")
      page.should have_selector('#tabs-head')  # Because we're still on edit page
    end

    it "should have blank line for new child" do
      @family = factory_family_bare :couple=>false, :child=>false
      visit edit_family_path(@family)
      page.should have_selector('#member_1000000001_first_name')
      fill_in 'member_1000000001_first_name', :with=>'Junior'
    end

    it "should add new child" do
      Factory(:employment_status, :description=>"MK dependent", :code=>"mk_dependent", :child=>true)
      @family = factory_family_bare :couple=>false, :child=>false
      visit edit_family_path(@family)
      page.should have_selector('#member_1000000001_first_name')
      fill_in 'member_1000000001_first_name', :with=>'Junior'
      fill_in 'member_1000000001_first_name', :with=>'Junior'
      fill_in 'member_1000000001_middle_name', :with=>'Z.'
      select 'Male', :from=> 'member_1000000001_sex'
      fill_in 'member_1000000001_birth_date', :with=>Date.today.strftime("%F")
      fill_in 'member_1000000001_school', :with=>'Hillcrest'
      fill_in 'member_1000000001_school_grade', :with=>'7'
      select('MK dependent')      
      click_button "Update"


      m = @family.children.last
      m.first_name.should == 'Junior'
      m.middle_name.should == 'Z.'
      m.sex.should == 'M'
      m.birth_date.should == Date.today
      m.school.should == 'Hillcrest'
      m.school_grade.should == 7
      m.employment_status_code.should == 'mk_dependent'
      m.last_name.should == @family.last_name
    end
          
    it "editing family should change all values correctly" do
      @family = factory_family_bare :couple=>true, :child=>true
      Factory(:employment_status, :description=>"MK dependent", :child=>true)
#      y @family.head
      birth_date = Date.new(1980,1,1)
      child_birth_date = Date.new(2000,12,31)
      temp_loc_from = Date.new(2011,1,1)
      temp_loc_until = Date.new(2011,1,10)
      date_active = Date.new(2000,2,1)
      field_term_start = Date.new(2000,4,4)
      field_term_end = Date.new(2004,4,4)
      est_field_term_start = Date.new(2000,5,4)
      est_field_term_end = Date.new(2004,5,4)
      phone_1 = '+2348887771111'
      phone_2 = '+2348887772222'
      email_1 = 'firstmail@test.com'
      email_2 = 'secondmail@test.com'

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
        select 'Career'    # employment status
        select 'Ministry'  # ministry description
        select 'On field'  # default status
        select 'Site', :from=>'Ministry location'
        fill_in 'Ministry comment', :with=> "ministry comment"
        fill_in 'Temporary location', :with=> "out of town"
        fill_in "head_temporary_location_from_date", :with => temp_loc_from.strftime("%F")
        fill_in "head_temporary_location_until_date", :with => temp_loc_until.strftime("%F")
        fill_in "Phone on field", :with => phone_1
        fill_in "Phone 2", :with => phone_2
        fill_in "Email 1", :with => email_1
        fill_in "Email 2", :with => email_2
        
      end # Within head tab

      within("#tabs-wife") do
        fill_in "First name", :with => "Bellana"
        fill_in "Middle name", :with => "Maria"
        fill_in "Short name", :with => "Bell"
        fill_in "Birth date", :with => birth_date.strftime("%F")
        select "Afg", :from=>'Country'
        select "Educ"
        fill_in "Qualifications", :with=> "Very qualified"

        fill_in "Full name", :with=>"Newman, Alfred A."
        fill_in "Date active", :with => date_active.strftime("%F")
        fill_in "Est. end of service", :with => (date_active+365.days).strftime("%F")
        select 'Career'
        select 'Ministry'
        select 'On field'  # default status
        select 'Site', :from=>'Ministry location'
        fill_in 'Ministry comment', :with=> "ministry comment"
        fill_in 'Temporary location', :with=> "out of town"
        fill_in "wife_temporary_location_from_date", :with => temp_loc_from.strftime("%F")
        fill_in "wife_temporary_location_until_date", :with => temp_loc_until.strftime("%F")
        fill_in "Phone on field", :with => phone_1
        fill_in "Phone 2", :with => phone_2
        fill_in "Email 1", :with => email_1
        fill_in "Email 2", :with => email_2
      end # Within wife tab

      within("#tabs-family") do
        fill_in "record_name", :with => "Newman, Alfred Q."
        fill_in "SIM ID", :with => '01234'
        select 'Site', :from=>'Residence location'
      end  

      within ("#tabs-children") do
        child_id = @family.children.first.id.to_s
        fill_in "member_#{child_id}_first_name", :with => "Andromeda"
        fill_in "member_#{child_id}_middle_name", :with => "Jo"
        fill_in "member_#{child_id}_birth_date", :with => child_birth_date.strftime("%F")
        select "Female", :from=>"member_#{child_id}_sex"
        fill_in "member_#{child_id}_school", :with => "Homeschool"
        fill_in "member_#{child_id}_school_grade", :with => "7"
        select "MK dependent", :from=>"member_#{child_id}_personnel_data_employment_status_id"
      end
      click_button "Update"

      page.should have_selector('h2', :content=>'Families')
      page.should have_no_selector('#errorExplanation')

      f = @family.reload
      # Check head data
      m = f.head.reload
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
      m.residence_location.description.should =~ /Site/  # because Family residence location was updated
      m.work_location.description.should  =~ /Site/
      m.temporary_location.should == 'out of town'
      m.temporary_location_from_date.should == temp_loc_from
      m.temporary_location_until_date.should == temp_loc_until
      m.personnel_data.employment_status.description.should =~ /Career/
      m.status.description.should =~ /field/
      m.primary_contact.phone_1.should == phone_1
      m.primary_contact.phone_2.should == phone_2
      m.primary_contact.email_1.should == email_1
      m.primary_contact.email_2.should == email_2
      
      # Check spouse data
      m = f.wife.reload
      m.first_name.should == 'Bellana'
      m.middle_name.should == 'Maria'
      m.short_name.should == 'Bell'
      m.sex.should == 'F'
      m.birth_date.should == birth_date
      m.country.name.should =~ /Afghanistan/
      m.personnel_data.education.description.should =~ /Educ/
      m.personnel_data.qualifications.should == "Very qualified"
      m.name.should == "Newman, Alfred A."
      m.personnel_data.date_active.should == date_active
      m.personnel_data.est_end_of_service.should == date_active+365.days
      m.ministry.description.should =~ /Min/
      m.ministry_comment.should ==   "ministry comment"    
      m.residence_location.description.should =~ /Site/  # because Family residence location was updated
      m.work_location.description.should  =~ /Site/
      m.temporary_location.should == 'out of town'
      m.temporary_location_from_date.should == temp_loc_from
      m.temporary_location_until_date.should == temp_loc_until
      m.status.description.should =~ /field/
      m.personnel_data.employment_status.description.should =~ /Career/
      m.primary_contact.phone_1.should == phone_1
      m.primary_contact.phone_2.should == phone_2
      m.primary_contact.email_1.should == email_1
      m.primary_contact.email_2.should == email_2

      # Check family data
      f.name.should == "Newman, Alfred Q."
      f.sim_id.should == '01234'
      f.residence_location.description.should =~ /Site/

      # Check child data
      c = f.children.first.reload
      c.first_name.should == 'Andromeda'
      c.middle_name.should == 'Jo'
      c.sex.should == 'F'
      c.birth_date.should == child_birth_date
      c.school.should == 'Homeschool'
      c.school_grade.should == 7
      c.personnel_data.employment_status.description.should == "MK dependent"
    end # editing family should change all values correctly

  end # describe by Admin
end # describe Families
