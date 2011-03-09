  require 'sim_test_helper'
  include SimTestHelper
    
  def construct_family
    @family = Factory.create(:family, :status=>@status, :residence_location=>@location)
    @head = @family.head
  end

  def construct_member(params={})
    m = Factory.create(:member, {:family=>@family}.merge(params))
  end
  
  def create_spouse(params={})
    @spouse_name = params[:first_name] || "Sally"
    @spouse = construct_member(:first_name=>@spouse_name, :sex=>"F", :spouse => @head)
  end

  def create_children(names=['Child'],params={})
    @children = []
    names.each do |name|
#puts "****+++ Constructing child #{name} #{@family.last_name}"
      @children << construct_member({:first_name => name}.merge(params))
    end  
  end  

  def set_up_statuses
    @status = Factory.create(:status)
  end
  
  def set_up_employment_statuses
    @employment_status = EmploymentStatus.create(:code=>200, :description => "EmploymentStatus")
    EmploymentStatus.create(:code=>300, :description => "MK dependent", :mk_default => true)
  end

Given /^that I am signed in$/ do
    return if cookies[:remember_token]
    user = Factory(:user)
    # There might already be countries (seed_tables may have been called). Otherwise
    #    we need to create them since we will be directed to members table, which 
    #    has a column for countries
    Factory(:country) unless Country.count > 0
    Factory(:country_unspecified) unless Country.exists?(UNSPECIFIED)
    visit signin_path
    fill_in "Name",    :with => user.name
    fill_in "Password", :with => user.password
    click_button "Sign in"
end

Given /^a one-person family$/ do
  construct_family
end

Given /^a family without a spouse$/ do
  construct_family
end

Given /^a family with a spouse$/ do
  construct_family
  @head.update_attributes(:sex=>'M')
  create_spouse
end

Given /^a family with a "([^"]*)" and "([^"]*)" and "([^"]*)"$/ do |spouse, child_1, child_2|
  construct_family
  if spouse != '--nil--'
    create_spouse({:first_name => spouse})
  end
  if child_1 != '--nil--'
    @child_1 = create_children([child_1])
  end
  if child_2 != '--nil--'
    @child_1 = create_children([child_2])
  end
#puts "****+++ Family constructed "
#@family.members.each {|m| puts "****+++ Member #{m.name}" }
end


When /^I ask to create a spouse$/ do
#puts "****+++#{new_member_path(:id=>@head.id, :spouse=>'spouse')}"
#puts "****+++ spouse_id = #{@head.id}, #{@head}"
  visit new_member_path(:id=>@head.id, :spouse=>'spouse')
end

Then /^I receive a valid form for a spouse$/ do
  find_field("record[spouse]").value.to_i.should == @head.id
  find_field("Last name").value.should == @head.last_name
  find_field("Family name").value.should have_content @head.last_name
  page.should have_content(@status.description)
  page.should have_content(@employment_status.description)
  find_field("Sex").value.should have_content('F')
end

When /^I ask to create a child$/ do
  visit new_member_path(:id=>@head.id, :child=>'child')
end

Then /^I receive a valid form for a child$/ do
  find_field("record[spouse]").value.should == ""
  find_field("Last name").value.should == @head.last_name
  find_field("Family name").value.should have_content @head.last_name
  page.should have_content("MK")
end

When /^I view the list of families$/ do
  visit families_path
end

When /^I edit the family head$/ do
  @head.add_details   # give @head the various attributes we're going to check on the form
  seed_tables
  visit edit_member_path @head
end  

Then /^I should see the editing form for the family head$/ do
  page.should have_content "Update #{@head.to_label}"
  find_field("Last name").value.should == @head.last_name
  find_field("First name").value.should == @head.first_name
  find_field("Sex").value.should == @head.sex
  find_field("record[spouse]").value.should == @spouse.id.to_s
  page.should have_content @spouse.first_name
  find_field("Country").value.should == @country.name
  find_field("Employment status").value.should == @head.employment_status_id.to_s
  find_field("Ministry").value.should == @head.ministry_id.to_s
  
end  

Then /^I see a link to add a spouse$/ do
  page.should have_content "Add spouse"
end

Then /^the family includes the head and spouse$/ do
  couple = @family.members
  couple.should have(2).records
  couple[0].name.should == @head.name
  couple[1].name.should == @spouse.name
end

Then /^I do not see a link to add a spouse$/ do
  page.should_not have_content "Add spouse"
end

Then /^I see the head of family$/ do
  page.should have_content @head.to_label
end

Then /^I see the "([^"]*)"$/ do |thing_to_see|
  if thing_to_see != '--nil--'
    page.should have_content thing_to_see
  else  
    page.should_not have_content '--nil--'
  end
end

When /^I enter names "([^"]*)" , "([^"]*)", "([^"]*)", and "([^"]*)"$/ do |last_name, first_name, middle_name, short_name|
  @member = Member.new(:last_name=> last_name, :first_name => first_name, :middle_name => middle_name, :short_name => short_name)
end

Then /^the new indexed name should be "([^"]*)"$/ do |name|
  @member.indexed_name.should == name
end

Then /^the member's family_id will be "([^"]*)"$/ do | new_family_id |
  
  @member.family_id.should == new_family_id.to_i
end

Then /^the "([^"]*)" family record will exist$/ do |arg1|
  f = Family.find(@member.family_id)
  f.should_not be nil
end

Given /^an existing member with a name "([^"]*)"$/ do |name|
  @member = construct_member(:name => name)
end

When /^I make a new member with name "([^"]*)"$/ do |name|
  @member = Member.new(:name => name, :first_name => 'A', :last_name => 'A')
end

Then /^the record will not be valid$/ do
  @member.should_not be_valid
end

Then /^it will show a duplication error$/ do
  @member.errors.should have_content("already been taken")
end

Given /^that detail tables \(like Countries\) exist$/ do
  seed_tables
end

When /^I select "new family"$/ do 
  visit new_family_path
end

When /^I select "update family"$/ do

  visit edit_family_path @family
end

Then /^I should see a valid form for updating a family$/ do
# save_and_open_page( )
#puts "@family.status_id=#{@family.status_id}, status=#{@family.status}"
##  page.should have_content Regexp.new("(Update|Edit|) .*#{@family.last_name}")
  find_field("record[name]").value.should == @family.name
#  find_field("Last name").value.should == @family.last_name
#  find_field("First name").value.should == @family.first_name
  find_field("SIM").value.should == @family.sim_id.to_s
  find_field("Status").value.should == @family.status_id.to_s
  find_field("Location").value.should == @family.residence_location_id.to_s
end

Given /^a form filled in for a new family$/ do
  seed_tables
  @family = Factory.build(:family)   # Not yet saved to database
  visit new_family_path
  fill_in("Last name", :with=> @family.last_name)
  fill_in("record[name]", :with=> @family.name)
  fill_in("First name", :with=> @family.first_name)
  fill_in("SIM", :with=> @family.sim_id)

end

Then /^the database should contain the new family$/ do
  Family.count.should == 1
  f = Family.first
  @head_id = f.head_id
#puts "f.id = #{f.id}, name=#{f.name}, sim_id=#{f.sim_id}"
  f = Family.find_by_sim_id(@family.sim_id)
  f.should_not be nil
end

Then /^I should see a form for editing the family head$/ do
#save_and_open_page( )
  href = "http://example.org/members/#{@head_id}/edit"
  page.should have_selector('a', :href=>href)
  find_field("First name").value.should == @family.first_name
end

Then /^I should see a valid form for a new family$/ do
#save_and_open_page( )
  page.should have_content "Create a New Individual or Family"
  find_field("record[last_name]").value.blank?.should be true
  find_field("First name").value.blank?.should be true
  find_field("SIM").value.blank?.should be true
#  find_field("record_status").element.search(".//option[@selected = \"selected\"]").inner_html.should =~ /unspecified/i
  find_field("record_status").value.should == "999999"
  find_field("record_residence_location").value.should == "999999"
  page.should have_content "Create a New Individual or Family"
  page.should have_content "Click to allow editing"
  page.should have_selector "input", :id=> 'record_name' 
end

Then /^I should see a customized form for a new family$/ do
#  find_field("First name").value.should == @family.first_name
#  find_field("SIM").value.should == @family.sim_id.to_s
#  find_field("Status").value.should == @family.status_id.to_s
#  find_field("residence_location").value.should == @family.residence_location_id.to_s
end

Then /^I should see a button for adding a spouse$/ do
  page.should have_link "Add spouse"
end

Then /^I should not see a button for adding a spouse$/ do
  page.should_not have_link "Add spouse"
end

Then /^I should see a button for adding a child$/ do
  page.should have_link "Add child" 
end

Given /^that I am updating a family$/ do
  seed_tables
  construct_family
  @head.add_details
  @head.status_id.should == @status.id
  @head.residence_location_id.should == @location.id
  visit edit_family_path :id=>@family.id
end

When /^I click on "([^"]*)"$/ do |button_to_click|
# save_and_open_page( )
  click_link_or_button button_to_click
end

Then /^I should see a form titled "([^"]*)"$/ do |title|
  page.should have_content title
#  x=find(:xpath, '//form').innerhtml
#  puts "find result=#{x}"
# save_and_open_page( )
end

Then /^the form should be pre\-set to add a spouse$/ do
  find_field("Last name").value.should == @family.last_name
  find_field("First name").value.blank?.should be true
  find_field("Sex").value.should == ApplicationHelper::opposite_sex(@head.sex)
  find_field("record[spouse]").value.should == @head.id.to_s
  find_field("Country name").value.should == @head.country.name
#  find_field("Date active").value.should == @head.date_active
  find_field("Status").value.to_s.should == @head.status_id.to_s
  find_field("record[residence_location]").value.to_s.should == @head.residence_location_id.to_s
end

Then /^the form should be pre\-set to add a child$/ do
  find_field("Last name").value.should == @family.last_name
  find_field("First name").value.blank?.should be true
#  find_field("Sex").value.should == ApplicationHelper::opposite_sex(@head.sex)
  find_field("record[spouse]").value.should == ''
  find_field("Country name").value.should == @head.country.name
#  find_field("Date active").value.should == @head.date_active
  find_field("Status").value.to_s.should == @head.status_id.to_s
  find_field("record[residence_location]").value.to_s.should == @head.residence_location_id.to_s
end

Given /^I am viewing the family list$/ do
  visit families_path
end

When /^I select the delete link$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see an error message$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the family should still be present$/ do
  pending # express the regexp above with the code you wish you had
end

###################### REPORTS #####################################

Then /^I should get a "([^"]*)" PDF report$/ do |target_text|
# Converts a PDF response to a text one, based on methods in 
# http://upstre.am/blog/2009/02/testing-pdfs-with-cucumber-and-rails
#puts "Converting the #{target_text} report from PDF to Text"
#puts "PDF Page.body = ::#{page.body}::"
  temp_pdf = Tempfile.new('pdf')
  temp_pdf << page.body.force_encoding('UTF-8')
  temp_pdf.close
#  temp_txt = Tempfile.new('txt')
#  temp_txt.close
#  `pdftotext -q #{temp_pdf.path} #{temp_txt.path}`
#  page.driver.instance_variable_set('@body', File.read(temp_txt.path))
  #The next line replaces the previous 4, though I don't know exactly how the last bit works!
  page.driver.instance_variable_set('@body', `pdftotext -enc UTF-8 -q #{temp_pdf.path} - 2>&1`)
  # next is a hack for now, to allow '{next month}' to mean we need to see next month's name in the report.
  if target_text == '{next month}'
    target_text = Date::MONTHNAMES[Date::today().next_month.month]  # which is the name for the next month from now
  end
#puts "Page.body = ::#{page.body}::"
  page.should have_content target_text
end

Given /^a member with phone "([^"]*)" and email "([^"]*)"$/ do |arg1, arg2|
  member = Fac
end
Given /^a contact record$/ do
  @contact = Factory(:contact, :member_id => @head.id)
end

Then /^the report should include the name, phone and email$/ do 
  page.should have_content @head.last_name
  page.should have_content @contact.phone_1
end

Given /^a "([^"]*)" record$/ do |record_type|
  @detail = case record_type
  when 'travel' then Factory(:travel, :member_id => @head.id, :date=> Date::tomorrow, :confirmed => Date::yesterday)
  end
# puts "Detail record created = #{@detail.attributes}"
end

Then /^the report should include the "([^"]*)" information$/ do |report_type|
  case report_type
  when 'travel'
    page.should have_content 'Travel Schedule'
    page.should have_content @head.last_name
    page.should have_content @detail.date.to_s
    page.should have_content @detail.origin
  end      
end


