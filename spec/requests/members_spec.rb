require 'spec_helper'
require 'sim_test_helper'

#require "webrat"

#Webrat.configure do |config|
#  config.mode = :rails
#end

def select_second_option(id)
# from Jason Neylon's Blog http://bit.ly/gIPq1R
# original  second_option_xpath = "//*[@id='#{id}']/option[2]"
  second_option_xpath = "//select[@id='#{id}']/option[2]"
  second_option = find(:xpath, second_option_xpath).text
  select(second_option, :from => id)
end

describe "Members" do
include SimTestHelper

  describe "by Administrator" do

    before(:each) do
      integration_test_sign_in(:admin=>true)
      @family = Factory(:family)
      @head = @family.head
      seed_tables
    end  

    it "should create a new member with minimal values" do
      lambda do
        visit new_member_path
        select_second_option('record_family_')  # Family 
        fill_in "Last name", :with => "#{@head.last_name}"
#        select("* #{@family.name}", :from=> 'record_family_')
        fill_in "First name", :with => "Sally"
        click_button "Create"
      end.should change(Member, :count).by(1)
      Member.last.first_name.should == 'Sally'
    end # it should

    it "should create a new user with all values filled in" do
      lambda do
        visit new_member_path
#save_and_open_page( )
        fill_in "Last name", :with => "#{@head.last_name}"
        select("* #{@family.name}", :from=> 'record_family_')
        fill_in "First name", :with => "Samuel"
        fill_in "Middle name", :with => "Jonah"
        fill_in "Short name", :with => "Sam"
        select('Male')
        check 'Child'  
        fill_in "Birth date", :with => "2000-01-01"
        fill_in "Country name", :with => "Afghanistan"
        select 'On field'
        select 'Evangelism'
        fill_in 'Ministry comment', :with=> "ministry comment"
        select 'JETS', :from=>'record_residence_location'
        select 'JETS', :from=>'record_work_location'
        fill_in 'Temporary location', :with=> "out of town"
        fill_in "Temporary location from date", :with => "2011-01-01"
        fill_in "Temporary location until date", :with => "2011-01-10"
        fill_in "Current meds", :with => "aspirin"
        fill_in "Issues", :with => "headaches"
        fill_in "Allergies", :with => "NKA"
        select 'AB+'
        select 'Educated!'
        fill_in "Qualifications", :with=> "Very qualified"
        select 'Career'
        fill_in "Date active", :with => "2000-02-01"
        fill_in "Comments", :with => "What a lot of info to fill in."
        click_button "Create"
      #save_and_open_page( )
      end.should change(Member, :count).by(1)
      m = Member.last
      m.first_name.should == 'Samuel'
      m.middle_name.should == 'Jonah'
      m.short_name.should == 'Sam'
      m.sex.should == 'M'
      m.child.should == true
      m.birth_date.should == Date.new(2000,1,1)
      m.country.name.should == 'Afghanistan'
      m.status.description.should =~ /On field/
      m.ministry.description.should == 'Evangelism'
      m.ministry_comment.should ==   "ministry comment"    
      m.residence_location.description.should == 'JETS'
      m.work_location.description.should == 'JETS'
      m.temporary_location.should == 'out of town'
      m.temporary_location_from_date.should == Date.new(2011,1,1)
      m.temporary_location_until_date.should == Date.new(2011,1,10)
      m.health_data.current_meds.should == 'aspirin'
      m.health_data.issues.should == 'headaches'
      m.health_data.allergies.should == 'NKA'
      m.health_data.bloodtype.full.should == 'AB+'
      m.personnel_data.education.description.should == 'Educated!'
      m.personnel_data.employment_status.description.should == 'Career'
      m.personnel_data.date_active.should == Date.new(2000,2,1)
      m.personnel_data.comments.should == 'What a lot of info to fill in.'
    end # it should

    

  end # Describe Members

end
