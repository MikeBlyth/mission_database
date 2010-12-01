Given /^a head of family$/ do
  @head = Member.new(:last_name=> 'Testing', :first_name => "John", :family_head => true, 
          :sex => "M", :birth_date => '1970-01-01')
  @head.name = @head.indexed_name
  @head.save
end

When /^I ask to create a spouse$/ do
  get 
end