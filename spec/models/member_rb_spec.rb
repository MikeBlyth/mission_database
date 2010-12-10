require 'spec_helper'

describe Member do
  before(:each) do
    @member = new_member
  end    

  def new_member
    Member.new(:last_name => "Last", :middle_name => 'Middle', :first_name => "First", :name=>"Last, first")
  end

  it "is valid with valid attributes" do
    @member.should be_valid
  end
  it "is not valid without a first name" do
    @member.first_name = ''
    @member.should_not be_valid
  end
  it "is not valid without a last name" do
    @member.last_name = ''
    @member.should_not be_valid
  end
  it "makes a 'name' (full name) by default" do
    @member.name = ''
    @member.should be_valid   # because set_indexed_name_if_empty is called before validation
  end
  it "is valid when creating its own 'name' (full name)" do
    @member.name = @member.indexed_name
    @member.should be_valid
  end
  it "is invalid if full name already exists in database" do
    @member.save # save the already-created members
    new_member.should_not be_valid
  end

end

