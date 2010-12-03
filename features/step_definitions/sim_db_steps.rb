  def construct_member(params={})
    m = Member.new({:last_name=> 'Testing', 
        :first_name => "Test_#{rand.to_s[2..5]}",
        :family_id => 1,
        :family_head => false,
          :sex => 'M', 
          :birth_date => '1970-01-01',
          }.merge(params)) 
    m.id = params[:id]
    m.name = "#{m.last_name}, #{m.first_name}"
    m.save
    m
  end
    
  def create_family_head(params={})
    head = construct_member({:first_name => "John", :family_head=>true}.merge(params))
    head
  end
  
  def create_spouse(params={})
    spouse = construct_member(:first_name=>"Sally", :sex=>"F", :spouse_id => @head.id)
  end  

  def create_children(n=1, params)
    children = []
    1.upto(n) do |x|
      children << construct_member({:first_name => "Child_#{x}"}.merge(params))
    end  
  end  

  # TODO: Replace with some kind of fixture
  def set_up_statuses
    @status = Status.create(:code => 100, :description => "TestStatus")
  end
  
  def set_up_employment_statuses
    @employment_status = EmploymentStatus.create(:code=>200, :description => "EmploymentStatus")
    EmploymentStatus.create(:code=>300, :description => "MK dependent", :mk_default => true)
  end

Given /^a family view$/ do
  # This stuff should probably be changed to a fixture somehow
  @head = create_family_head({:status_id => 1, :employment_status_id => 1})
  set_up_statuses
  set_up_employment_statuses
end

Given /^a family without a spouse$/ do
  @head = create_family_head({:status_id => 1, :employment_status_id => 1})
  @spouse = nil
end

Given /^a family with a spouse$/ do
  @head = create_family_head({:status_id => 1, :employment_status_id => 1})
  @spouse = create_spouse
end

Given /^a family with a "([^"]*)" and "([^"]*)" and "([^"]*)"$/ do |spouse, child_1, child_2|
  @head = create_family_head({:status_id => 1, :employment_status_id => 1})
  if spouse != '--nil--'
    @spouse = create_spouse(:first_name => spouse)
  end
  if child_1 != '--nil--'
    @child_1 = create_children(:first_name => child_1)
  end
  if child_2 != '--nil--'
    @child_1 = create_children(:first_name => child_2)
  end
end


When /^I ask to create a spouse$/ do
  visit family_path(@head.family_id)
  click_link "Add spouse" 
end

Then /^I receive a valid form for a spouse$/ do
  field_named("record[spouse]").value.should == "1"
  field_labeled("Last name").value.should == @head.last_name
  field_labeled("Family name").value.should contain @head.last_name
  response.should contain(@status.description)
  response.should contain(@employment_status.description)
  field_labeled("Sex").value.should contain('F')
end

When /^I ask to create a child$/ do
  visit family_path(@head.family_id)
  click_link "Add child" 
end

Then /^I receive a valid form for a child$/ do
  field_named("record[spouse]").value.should == ""
  field_labeled("Last name").value.should == @head.last_name
  field_labeled("Family name").value.should contain @head.last_name
  response.should contain("MK")
end

When /^I view the family$/ do
  visit family_path(@head.family_id)
end

Then /^I see a link to add a spouse$/ do
  response.should contain "Add spouse"
end

Then /^I do not see a link to add a spouse$/ do
  response.should_not contain "Add spouse"
end

Then /^I see the head of family$/ do
  response.should contain @head.to_label
end

Then /^I see the "([^"]*)"$/ do |arg1|
  if arg1 == '---nil--'
    response.should contain arg1 
  else  
    response.should_not contain '--nil--'
  end
end

