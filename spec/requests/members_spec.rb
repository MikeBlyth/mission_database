require 'spec_helper'
require '~/simjos/spec/support/sim_test_helper'

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
    end  
    
    it 'avoids "ambiguous status_id" bug', :slow=>true do  # make a controller test if we need this
      @head = factory_member_basic
      visit root_path
      click_link "Active only"
    end

    it 'allows inline editing in list view' do
#      @family = factory_family_full(:couple => true)
#      @head = @family.head
      head = Factory(:member_with_details)
      location2 = Factory(:location, :description=>'second location')
      visit root_path
#      find('.child-column input[type=checkbox]').click
      check('record[child]')
      find('td.work_location-column span').click
      select('second location')
      click_on('inplace_save')
      save_and_open_page
      page.should have_content(head.name)
    end

    it "editing user should change all values correctly" do
#puts "Start editing: #{Time.now}"
      @head = factory_member_basic
      @family = @head.family
      seed_tables
      phone_1 = '+2348887771111'
      phone_2 = '+2348887772222'
      email_1 = 'firstmail@test.com'
      email_2 = 'secondmail@test.com'
      birth_date = Date.new(2000,1,1)
      temp_loc_from = Date.new(2011,1,1)
      temp_loc_until = Date.new(2011,1,10)
      date_active = Date.new(2000,2,1)
      field_term_start = Date.new(2000,4,4)
      field_term_end = Date.new(2004,4,4)
      est_field_term_start = Date.new(2000,5,4)
      est_field_term_end = Date.new(2004,5,4)
      visit edit_member_path(@head)
      fill_in "First name", :with => "Samuel"
      fill_in "Middle name", :with => "Jonah"
      fill_in "Short name", :with => "Sam"
      select('Female')
      fill_in "Birth date", :with => birth_date.strftime("%F")
      select "Afg", :from=>'Country'
      select 'On field'
      select 'Ministry'
      fill_in 'Ministry comment', :with=> "ministry comment"
#*      select 'Site', :from=>'record_residence_location'
      select 'Site', :from=>'Ministry location'
      fill_in 'Temporary location', :with=> "out of town"
      fill_in "head_temporary_location_from_date", :with => temp_loc_from.strftime("%F")
      fill_in "head_temporary_location_until_date", :with => temp_loc_until.strftime("%F")
      fill_in "Phone on field", :with => phone_1
      fill_in "Phone 2", :with => phone_2
      fill_in "Email 1", :with => email_1
      fill_in "Email 2", :with => email_2

      fill_in "health_data_current_meds", :with => "aspirin"
      fill_in "health_data_issues", :with => "headaches"
      fill_in "health_data_allergies", :with => "NKA"
      fill_in "health_data_comments", :with => "good"
      select 'AB+'
      select 'Educ'
      fill_in "Qualifications", :with=> "Very qualified"
      select 'Career', :from => 'Employment status'
      fill_in "Date active", :with => date_active.strftime("%F")
      fill_in "head_pers[comments]", :with => "What a lot of info to fill in."
      click_button "Update"

      m = @head.reload
      m.first_name.should == 'Samuel'
      m.middle_name.should == 'Jonah'
      m.short_name.should == 'Sam'
      m.sex.should == 'F'
      m.birth_date.should == birth_date
      m.country.name.should == Country.first.name
      m.status.description.should =~ /On field/
      m.ministry.description.should =~ /Min/
      m.ministry_comment.should ==   "ministry comment"    
      m.work_location.description.should  =~ /Site/
      m.temporary_location.should == 'out of town'
      m.temporary_location_from_date.should == temp_loc_from
      m.temporary_location_until_date.should == temp_loc_until
      m.health_data.current_meds.should == 'aspirin'
      m.health_data.issues.should == 'headaches'
      m.health_data.allergies.should == 'NKA'
      m.health_data.comments.should == 'good'
      m.health_data.bloodtype.full.should == 'AB+'
      m.personnel_data.education.description.should =~ /Educ/
      m.personnel_data.employment_status.description.should =~ /Career/
      m.personnel_data.date_active.should == date_active
      m.personnel_data.comments.should == 'What a lot of info to fill in.'
    end

  end # Describe by Admin

  describe "Access control:" do
      before(:each) do
  #      integration_test_sign_in(:admin=>true)
        @head = factory_member_basic
        @family = @head.family
      end  

    it 'should not show edit form when not authorized' do
      integration_test_sign_in(:admin=>false)
      visit edit_member_path(@head)
      page.should have_content "not authorized"
      #save_and_open_page
    end    

    it 'should show personnel but not health tab for personnel role' do
      integration_test_sign_in(:admin=>false, :personnel=>true)
      visit edit_member_path(@head)
      page.should have_no_content "not authorized"
      page.should have_selector "#tabs-member"
      page.should have_no_selector "#tabs-health"
      page.should have_selector "#tabs-personnel"
    end    

    it 'should show health but not personnel tab for medical role' do
      integration_test_sign_in(:admin=>false, :medical=>true)
      visit edit_member_path(@head)
      page.should have_no_content "not authorized"
      page.should have_selector "#tabs-member"
      page.should have_selector "#tabs-health"
      page.should have_no_selector "#tabs-personnel"
    end    

    it 'should show only member tab for travel role' do
      integration_test_sign_in(:admin=>false, :travel=>true)
      visit edit_member_path(@head)
      page.should have_no_content "not authorized"
      page.should have_selector "#tabs-member"
      page.should have_no_selector "#tabs-health"
      page.should have_no_selector "#tabs-personnel"
    end    

  end

end # Describe Members


