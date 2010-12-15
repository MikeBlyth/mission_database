require 'spec_helper'


describe Member do
  before(:each) do
    @status = Factory.create(:status)
    @family = Factory.create(:family)
    @member = new_family_member    # This is in addition to the family_head, which is *saved* on creation of a family
                            #   This second family member @member is *not* saved yet
  end    

  def new_family_member
    Factory.build(:member, :family=>@family)
  end

  ## FOR DEBUGGING ONLY
  def puts_member(m, tag='member')
    puts "****+++ #{tag}: #{m.to_s}, id=#{m.id}, status_id=#{m.status_id}, family_id=#{m.family_id}"
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

  it "is invalid without a matching family" do
    @member.family_id = 999
    @member.should_not be_valid
  end

  it "cannot be deleted if it is the family head" do
    Member.should have(1).record
    @family.head.destroy
    @family.head.errors[:delete].should include "Can't delete head of family."
    Member.should have(1).record
  end
 
  it "can be deleted if it is not the family head" do
    @member.save    # member is not the head
    Member.should have(2).records
    @member.destroy
    Member.should have(1).record
  end

  it "is invalid if full name already exists in database" do
    @member.name  = @family.head.name
    @member.should_not be_valid
  end

  it "copies inherited fields from family when new" do
    @member.last_name.should == @family.last_name
    @member.status_id.should == @family.status_id
    @member.location_id.should == @family.location_id
    
  end
  
  it "does not copy inherited fields from family when NOT new" do
    @member.last_name = "something else"
    @member.save!
    retrieved = Member.find(@member.id)  # re-read record from DB or at least cache
    retrieved.last_name.should_not == @family.last_name
  end
  
end

