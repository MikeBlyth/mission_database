  def construct_family
#puts "\n****+++ Constructing a family "
    @family = Family.create!(:last_name=>'Robertson', :first_name=>'Alan', 
      :middle_name=>'K.', :name=>'Robertson, Alan', :status_id=>1, :location_id=>1,
      :sim_id => '99'
      )
    @head = @family.head
  end

  def construct_member(params={})
#puts "****+++ Starting construct member, Member.count = #{Member.count}, params=#{params}"
    m = @family.members.new( { 
        :first_name => "Test_#{rand.to_s[2..5]}",
        :family_head => false,
        :sex => 'M', 
        :birth_date => '1970-01-01',
        }.merge(params) ) 
    m.id = params[:id]   # allow override -- not sure this is needed still
#    name = "#{m.last_name}, #{m.first_name}" if name.empty?
    m.save!
    @member_save_errors = m.errors
#puts "****++++ new member constructed: #{m} (Errors: #{m.errors})"  
    m
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

  # TODO: Replace with some kind of fixture?
  def set_up_statuses
    @status = Status.create(:code => 100, :description => "TestStatus")
  end
  
  # TODO: Replace with some kind of fixture?
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

######## LINKING MEMBERS & FAMILIES ##########

Given /^a single family record existing with ID=100$/ do
    @member = construct_member(:id => 100, :family_id => 100, :family_head => true)
end

When /^I add a member ID=101 with "([^"]*)" and "([^"]*)"$/ do |id, family_head|
  @families = Family.count
  @member = construct_member(:id => 101, :family_id => id, :family_head => family_head)
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


