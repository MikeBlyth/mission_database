require 'spec_helper'
require 'sim_test_helper'

def select_second_option(id)
# from Jason Neylon's Blog http://bit.ly/gIPq1R
# original  second_option_xpath = "//*[@id='#{id}']/option[2]"
  second_option_xpath = "//select[@id='#{id}']/option[2]"
  second_option = find(:xpath, second_option_xpath).text
  select(second_option, :from => id)
end

describe "Members" do
include SimTestHelper

  describe "by admin" do

    before(:each) do
      integration_test_sign_in(:admin=>true)
      @head = factory_member_basic
      @family = @head.family
      seed_tables
    end  

    it "should create a new user with all values filled in" do
      lambda do
        visit new_member_path
# save_and_open_page
        fill_in "Last name", :with => "#{@head.last_name}"
        select("#{@family.name}", :from=> 'record[family]')
        fill_in "First name", :with => "Samuel"
        fill_in "Middle name", :with => "Jonah"
        fill_in "Short name", :with => "Sam"
        select('Male')
        check 'Child'  
        fill_in "Birth date", :with => "2000-01-01"
        fill_in "Country name", :with => Country.first.name
        f = find_field('record[status]')
        select 'On field', :from=>'record[status]'
        select 'Ministry', :from=>'record[ministry]'
#        puts "f=#{f.native}"
#        select_second_option(:record_status_id)
#        select_second_option(:ministry_id)
        fill_in 'Ministry comment', :with=> "ministry comment"
        select 'Site', :from=>'record_residence_location'
        select 'Site', :from=>'record_work_location'
        fill_in 'Temporary location', :with=> "out of town"
        fill_in "record[temporary_location_from_date]", :with => "2011-01-01"
        fill_in "record[temporary_location_until_date]", :with => "2011-01-10"
        fill_in "Current meds", :with => "aspirin"
        fill_in "Issues", :with => "headaches"
        fill_in "Allergies", :with => "NKA"
        select 'AB+'
        select 'Educ'
        fill_in "Qualifications", :with=> "Very qualified"
        select 'Career'
        fill_in "Date active", :with => "2000-02-01"
        fill_in "record[personnel_data][comments]", :with => "What a lot of info to fill in."
        click_button "Create"
      end.should change(Member, :count).by(1)
      m = Member.last
#puts "After filled in, member=#{m.attributes}"
      m.family_id.should == @family.id
      m.first_name.should == 'Samuel'
      m.middle_name.should == 'Jonah'
      m.short_name.should == 'Sam'
      m.sex.should == 'M'
      m.child.should == true
      m.birth_date.should == Date.new(2000,1,1)
      m.country.name.should == Country.first.name
      m.status.description.should =~ /On field/
      m.ministry.description.should =~ /Min/
      m.ministry_comment.should ==   "ministry comment"    
      m.residence_location.description.should =~ /Site/
      m.work_location.description.should  =~ /Site/
      m.temporary_location.should == 'out of town'
      m.temporary_location_from_date.should == Date.new(2011,1,1)
      m.temporary_location_until_date.should == Date.new(2011,1,10)
      m.health_data.current_meds.should == 'aspirin'
      m.health_data.issues.should == 'headaches'
      m.health_data.allergies.should == 'NKA'
      m.health_data.bloodtype.full.should == 'AB+'
      m.personnel_data.education.description.should =~ /Educ/
      m.personnel_data.employment_status.description.should =~ /Career/
      m.personnel_data.date_active.should == Date.new(2000,2,1)
      m.personnel_data.comments.should == 'What a lot of info to fill in.'
    end # it should

    it "should create a new member with minimal values" do
      lambda do
        visit new_member_path
        fill_in "Last name", :with => "#{@head.last_name}"
        fill_in "First name", :with => "Sally"
        click_button "Create"
      end.should change(Member, :count).by(1)
      Member.last.first_name.should == 'Sally'
    end # it should

    it "editing user should change all values correctly" do
      @new_family = Factory(:family, :name=>'New Family')
      birth_date = Date.new(2000,1,1)
      temp_loc_from = Date.new(2011,1,1)
      temp_loc_until = Date.new(2011,1,10)
      date_active = Date.new(2000,2,1)
      field_term_start = Date.new(2000,4,4)
      field_term_end = Date.new(2004,4,4)
      est_field_term_start = Date.new(2000,5,4)
      est_field_term_end = Date.new(2004,5,4)
      visit edit_member_path(@head)
      select("#{@new_family.name}", :from=> 'record[family]')
      fill_in "First name", :with => "Samuel"
      fill_in "Middle name", :with => "Jonah"
      fill_in "Short name", :with => "Sam"
      select('Female')
      check 'Child'  
      fill_in "Birth date", :with => birth_date.strftime("%F")
      fill_in "Country name", :with => Country.first.name
      select 'On field', :from=>'record[status]'
      select 'Ministry', :from=>'record[ministry]'
      fill_in 'Ministry comment', :with=> "ministry comment"
      select 'Site', :from=>'record_residence_location'
      select 'Site', :from=>'record_work_location'
      fill_in 'Temporary location', :with=> "out of town"
      fill_in "record[temporary_location_from_date]", :with => temp_loc_from.strftime("%F")
      fill_in "record[temporary_location_until_date]", :with => temp_loc_until.strftime("%F")
      fill_in "Current meds", :with => "aspirin"
      fill_in "Issues", :with => "headaches"
      fill_in "Allergies", :with => "NKA"
      select 'AB+'
      select 'Educ'
      fill_in "Qualifications", :with=> "Very qualified"
      select 'Career'
      fill_in "Date active", :with => date_active.strftime("%F")
      fill_in "record[personnel_data][comments]", :with => "What a lot of info to fill in."
      ft_div = "as_members-#{@head.id}-field_terms-subform-div"
      within("div##{ft_div}") do # Field term subform
        fill_in 'Start date', :with => field_term_start.strftime("%F")
        fill_in 'End date', :with => field_term_end.strftime("%F")
        fill_in 'Est start date', :with => est_field_term_start.strftime("%F")
        fill_in 'Est end date', :with => est_field_term_end.strftime("%F")
        select 'Ministry', :from=>'Ministry'
        select 'Site'#, :from=>'record_primary_work_location'
        select 'Career'
      end
#save_and_open_page
      click_button "Update"

      m = @head.reload
#puts "After filled in, member=#{m.attributes}"
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
    
    describe "adding new member" do
    
      before(:each) do 
        visit new_member_path
        fill_in "Last name", :with => "#{@head.last_name}"
        fill_in "First name", :with => "Sally"
      end        

      it "should add a corresponding health_data record" do
        lambda do
          click_button "Create"
        end.should change(HealthData, :count).by(1)
      end  

      it "should add a corresponding personnel_data record" do
        lambda do
          click_button "Create"
        end.should change(PersonnelData, :count).by(1)
      end  

      it "should not add a new field_term" do
        lambda do
          click_button "Create"
        end.should_not change(FieldTerm, :count)
      end  

      it "should not add a new contact" do
        lambda do
          click_button "Create"
        end.should_not change(Contact, :count)
      end  

      it "should not add a new travel" do
        lambda do
          click_button "Create"
        end.should_not change(Travel, :count)
      end  

    end # adding new member

  end # Describe Members

end
