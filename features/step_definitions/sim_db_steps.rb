  require 'sim_test_helper'
  
  def construct_family
    @family = Factory.create(:family)
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

Given /^a one-person family$/ do
  # This stuff should probably be changed to a fixture somehow
  set_up_statuses
  set_up_employment_statuses
  construct_family
end

Given /^a family without a spouse$/ do
  set_up_statuses
  set_up_employment_statuses
  construct_family
end

Given /^a family with a spouse$/ do
  construct_family
  @head.update_attributes(:sex=>'M')
  create_spouse
  @spouse.update_attributes(:sex=>'F')
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
  field_named("record[spouse]").value.to_i.should == @head.id
  field_labeled("Last name").value.should == @head.last_name
  field_labeled("Family name").value.should contain @head.last_name
  response.should contain(@status.description)
  response.should contain(@employment_status.description)
  field_labeled("Sex").value.should contain('F')
end

When /^I ask to create a child$/ do
  visit new_member_path(:id=>@head.id, :child=>'child')
end

Then /^I receive a valid form for a child$/ do
  field_named("record[spouse]").value.should == ""
  field_labeled("Last name").value.should == @head.last_name
  field_labeled("Family name").value.should contain @head.last_name
  response.should contain("MK")
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
  response.should contain "Update #{@head.to_label}"
  field_labeled("Last name").value.should == @head.last_name
  field_labeled("First name").value.should == @head.first_name
  field_labeled("Sex").value.should == @head.sex
  field_named("record[spouse]").value.should == @spouse.id.to_s
  response.should contain @spouse.first_name
  field_labeled("Country").value.should == @country.name
  field_labeled("education").value.should == @head.education_id.to_s
  field_labeled("employment status").value.should == @head.employment_status_id.to_s
  field_labeled("ministry").value.should == @head.ministry_id.to_s
  
end  

Then /^I see a link to add a spouse$/ do
  response.should contain "Add spouse"
end

Then /^the family includes the head and spouse$/ do
  couple = @family.members
  couple.should have(2).records
  couple[0].name.should == @head.name
  couple[1].name.should == @spouse.name
end

Then /^I do not see a link to add a spouse$/ do
  response.should_not contain "Add spouse"
end

Then /^I see the head of family$/ do
  response.should contain @head.to_label
end

Then /^I see the "([^"]*)"$/ do |thing_to_see|
  if thing_to_see != '--nil--'
    response.should contain thing_to_see
  else  
    response.should_not contain '--nil--'
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
  @member.errors.should contain("already been taken")
end

Given /^that detail tables \(like Countries\) exist$/ do
  seed_tables
end

When /^I select "new family"$/ do 
  visit new_family_path
end

When /^I select "update family"$/ do
Factory.create(:status)
  visit edit_family_path @family
end

Then /^I should see a valid form for a new family$/ do
  response.should contain "Create Family"
  response.should contain "Create Family"
  field_labeled("Last name").value.blank?.should be true
  field_labeled("First name").value.blank?.should be true
  field_labeled("SIM").value.blank?.should be true
  field_labeled("Status").value.blank?.should be true
  field_labeled("Location").value.blank?.should be true
end

Then /^I should see a valid form for updating a family$/ do
puts "@family.status_id=#{@family.status_id}, status=#{@family.status}"
  response.should contain Regexp.new("Update .*#{@family.last_name}")
  field_labeled("Last name").value.should == @family.last_name
  field_labeled("First name").value.should == @family.first_name
  field_labeled("SIM").value.should == @family.sim_id.to_s
  field_labeled("Status").value.should == @family.status_id.to_s
  field_labeled("Location").value.should == @family.location_id.to_s
end

Given /^a form filled in for a new family$/ do
  seed_tables
  @family = Factory.build(:family)   # Not yet saved to database
  f=@family
puts "f.id = #{f.id}, name=#{f.name}, sim_id=#{f.sim_id}"
  visit new_family_path
  fill_in("Last name", :with=> @family.last_name)
  fill_in("record[name]", :with=> @family.name)
  fill_in("First name", :with=> @family.first_name)
  fill_in("SIM", :with=> @family.sim_id)

end

Then /^the database should contain the new family$/ do
  Family.count.should == 1
  f = Family.first
puts "f.id = #{f.id}, name=#{f.name}, sim_id=#{f.sim_id}"
  f = Family.find_by_sim_id(@family.sim_id)
  f.should_not be nil
end

Then /^I should see a form for editing the family head$/ do
save_and_open_page( ) 
  response.should contain Regexp.new("Update .*#{@family.last_name}")
  response.should contain "Country name"
end

