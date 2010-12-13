require 'spec_helper'


describe Member do
  before(:each) do
    @family = Factory.create(:family)
    @member = new_member    # This is in addition to the family_head, which is *saved* on creation of a family
                            #   This second family member @member is *not* saved yet
  end    

  def new_member
    @family.members.new(:last_name => "Last", :middle_name => 'Middle', :first_name => "Sally", :name=>"Last, Sally")

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

  it "is invalid without a family_id" do
    @member.family_id = nil
    @member.should_not be_valid
  end

  it "cannot be deleted if it is the family head" do
    head = @family.head
    Member.should have(1).record
    destroyed = head.destroy
    destroyed.should == false
    head.errors[:delete].should include "Can't delete head of family."
    Member.should have(1).record
  end

  it "can be deleted if it is not the family head" do
    @member.family_head = false   # Make explicit what is default anyway
    @member.save
    Member.should have(2).records
    @member.destroy
    Member.should have(1).record
  end

  it "is invalid if full name already exists in database" do
    v = new_member
    v.name = @family.head.name
    v.should_not be_valid
  end


end

