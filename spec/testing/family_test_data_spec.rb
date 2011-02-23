require 'spec_helper'
require 'application_helper'
require 'sim_test_helper'
require 'family_test_data'
include FamilyTestData

describe FamilyTestData do
include SimTestHelper


  before(:each) do
    # Start each test with a family and family head already
    # existing.
    @head = make_a_single
  end    

  it "creates a new single with family" do
    lambda do
      make_a_single
    end.should change(Family, :count).by 1
  end

  it "creates single with right sex" do
    make_a_single("M").sex.should == 'M'
    make_a_single("F").sex.should == 'F'
  end

  it "creates single with right s  it 'creates a child with right age and name' do
    child = add_child(@head,10)
    child.age.should == '10 years'
    child.last_name.should == @head.last_name    
  end

tatus" do
    make_a_single(nil,'F').status.code.should == 'F'
  end

  it "creates three new singles with family" do
    lambda do
      3.times {make_a_single}
    end.should change(Family, :count).by 3
  end

  it "creates a spouse" do
    lambda do
      add_spouse(@head)
    end.should change(Member, :count).by 1
  end

  it "creates a linked spouse with same last name and opposite sex" do
    spouse = add_spouse(@head)
    spouse.last_name.should == @head.last_name
    spouse.sex.should_not == @head.sex
    spouse.spouse.should == @head
    @head.spouse.should == spouse
  end
  
  it 'creates a child with right status' do
    @head.update_attributes(:status=>Status.find_by_code('field')
    child = add_child(@head,10)
    child.age.should == '10 years'
    child.last_name.should == @head.last_name    
  end

end


