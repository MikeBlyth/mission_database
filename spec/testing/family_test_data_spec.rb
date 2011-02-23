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
        t.send(key).should == params[key]          
      end          
    end #it 'creates a travel record with all the specified parameters'

# ** COMMENTED OUT JUST TO SAVE TIME -- They're a bit slow
    it 'calculates total travelers when traveler is alone' do
      add_travel(@head, :other_travelers_count=>0,
          :with_spouse=>false, :with_children=>false).total_passengers.should == 1
    end

    it 'calculates total travelers when traveler is accompanied' do
      add_spouse(@head)
      2.times {add_child(@head,10)}
      add_travel(@head, :other_travelers_count=>2,
          :with_spouse=>true, :with_children=>true).total_passengers.should == 6
    end

    it 'generates names for other travelers' do
      t = add_travel(@head, :other_travelers_count=>3)
      t.other_travelers.length.should > 25
      t.other_travelers.count(',').should == 2  # Three names separated by 2 commas
    end  
  end # Travel records

  describe 'Field terms' do

#  location_id          :integer(4)      default(999999)
#  ministry_id          :integer(4)      default(999999)
#  start_date           :date
#  end_date             :date
#  est_start_date       :date
#  est_end_date         :date
#  employment_status_id :integer(4)      default(999999)

    it 'creates a field term record' do
      lambda do
        add_field_term(@head)
      end.should change(FieldTerm, :count).by 1
    end

    it 'creates a field_term record with all the specified parameters' do
      params={:location =>Location.random, :ministry=>Ministry.random,
          :start_date=>'1994-01-01'.to_date, :end_date=>'1996-06-06'.to_date,
          :est_start_date=>'1994-01-01'.to_date, :est_end_date=>'1996-06-06'.to_date,
          :employment_status=>EmploymentStatus.random}
      t = add_field_term(@head,params)
      params.each do |key, value|
        t.send(key).should == params[key]          
      end          
    end  
          

    it 'past field term record has reasonable starting and ending dates' do
      f = add_field_term(@head)
      f.start_date.should == @head.date_active
      term_duration_days = (f.end_date - f.start_date).to_i
      term_duration_days.should > 180
      term_duration_days.should < 365*4+1
    end

    it 'makes a second term start after the end of the first term' do
      first_term = add_field_term(@head, :duration=>30)
      second_term = add_field_term(@head)
      (second_term.start_date - first_term.end_date).to_i.months.should > 1.month
    end
  
  end  # describe 'Field terms' do

end


