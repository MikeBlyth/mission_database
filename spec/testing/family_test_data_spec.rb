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

  describe "Creates family members" do
    def match_mk_status(parent_status, child_status)
      @head.update_attributes(:status=>Status.find_by_code(parent_status))
      child = add_child(@head,10)
      child.status.code.should == child_status
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

    it "creates single with right status" do
      make_a_single(nil,'field').status.code.should == 'field'
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
    
    it 'creates a child with right age' do
      child = add_child(@head,10)
      child.age.should == '10 years'
    end

    it 'creates a child with correct status based on parent\'s status' do
      parent_child_status = {'field'=>'mkfield', 'alumni'=>'mkalumni', 'home_assignment'=>'home_assignment',
              'pipeline'=>'pipeline', 'leave'=>'leave', 'unspecified'=>'unspecified', 'deceased'=>'unspecified'}
      parent_child_status.each { |parent_status, child_status| match_mk_status(parent_status, child_status) }
    end
  end # Creates family members

  describe 'Contact records' do
    
    it 'creates a contact record' do
      lambda do
        add_contact(@head)
      end.should change(Contact, :count).by 1
    end

    it 'creates contact record of specified type' do
      add_contact(@head,5).contact_type.code.should == 5
    end

    it 'uses member\'s name for field contact' do
      add_contact(@head,1).contact_name.should == @head.name
    end
    
    it 'uses member\'s name for home contact' do
      add_contact(@head,2).contact_name.should == @head.name
    end
    
    it 'uses member\'s last name for spouse contact' do
      add_contact(@head,3).contact_name.should =~ Regexp.new(@head.last_name)
    end
    
    it 'includes phone and email for field contact' do
      c = add_contact(@head,1)
      c.phone_1.should_not be_blank
      c.email_1.should_not be_blank
    end

    it 'includes address, phone and email for home contact' do
      c = add_contact(@head,2)
      c.address.should_not be_blank
      c.phone_1.should_not be_blank
      c.email_1.should_not be_blank
    end

  end # Contact records
  
  describe "travel records" do

    it 'creates a travel record' do
      lambda do
        add_travel(@head)
      end.should change(Travel, :count).by 1
    end

    it 'creates a travel record with right date' do
        add_travel(@head, :date => Date::tomorrow).date.should == Date::tomorrow
    end

    it 'creates a travel record with all the specified parameters' do
      params = {:date => Date::tomorrow, :origin => 'LAX', :destination => 'Abuja', :purpose => 'vacation',
                :guesthouse => 'Lutheran', :return_date => Date::today + 1.month, 
                :with_spouse => true, :with_children=>true,
                :total_passengers => 6,
                :other_travelers => 'Bob, Sally, Jean',
                :flight => "BA449",
                :baggage => 10}
      t = add_travel(@head,params)
      params.each do |key, value|
puts "**** #{key} = #{value}"
        t.send(key).should == params[key]          
      end          
    end


  end # Travel records
  
end


