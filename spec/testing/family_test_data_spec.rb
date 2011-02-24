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
    @head = make_a_single(:date_active=>Date::today.years_ago(20), :age=>45.0, :status=>'field')
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
      make_a_single(:sex=>"M").sex.should == 'M'
      make_a_single(:sex=>"F").sex.should == 'F'
    end

    it "creates single with right status" do
      make_a_single(:status_code=>'field').status.code.should == 'field'
    end

    it "creates single with right age" do
      5.times do
        h = make_a_single(:max_age=>30, :min_age=>30)
        h.age_years.should > 28
        h.age_years.should < 32
      end
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
      term_duration_days.should > 27
      term_duration_days.should < 365*4+1
    end

    it 'makes a second term start after the end of the first term' do
      first_term = add_field_term(@head, :duration=>30)
      second_term = add_field_term(@head)
      (second_term.start_date - first_term.end_date).to_i.months.should > 1.month
    end

    it 'does not add field terms with future date' do
      f = add_field_term(@head, :start_date => Date.today + 1.month)
      f.should be_nil
    end
  
  end  # describe 'Field terms' do

  describe 'It makes a dataset' do
  
    it 'makes multiple singles' do
      lambda do
        add_some_singles 3
      end.should change(Member, :count).by 3
    end
    
    it 'makes multiple couples' do
      lambda do
        add_some_couples 3
      end.should change(Member, :count).by 6
    end

#    describe 'adds children' do

#      before(:each) do
#        @head.family.destroy  # Get rid of the family created by default, or else change the before(:each) at top level
#        add_some_couples(30, :max_age=>50)
#        # All families should have 2 members now
#        Family.all.each {|f| f.members.count.should == 2}
#        add_some_children
#      end
#      
#      it 'adds some children' do
#        Family.all.each do |f|
#          report = "#{f.head.age}, #{f.members.count-2} children ("
#          f.members.find(:all, :offset=>2).each do |kid|
#            report << "#{kid.age}, "
#          end
#          report << ")"
#          puts report
#        end  
#      end # it adds some children

#      it 'ensures all children are born in the past' do
#        Member.where(:spouse_id => nil).each do |kid| # in this test, that means all the children
#          kid.age_years.should >= 0
#        end  
#      end # it ensures all children...
#    end # describe adds children

    describe 'travel records' do
    
      before(:each) do
puts "\n\nAdding singles"
        add_some_singles(5)
puts "Adding couples"
        add_some_couples(5)
puts "Adding children"
        add_some_children
puts "Adding field terms"
        add_some_field_terms
      end
      
      it 'adds some travel records' do
puts "Add some travel records"
        add_travels_for_field_terms
        Travel.count.should > 0
      end
    
      it 'adds travel to cover each term' do
puts 'adds travel to cover each term' 
        add_travels_for_field_terms
        FieldTerm.all.each do |term|
          Travel.find_by_member_id_and_date(term.member_id, term.start_date).should_not be_nil
          if term.end_date < Date::today
            Travel.find_by_member_id_and_date(term.member_id, term.end_date).should_not be_nil
          end
        end            
      end
    
      it 'adds travel in middle of term' do
puts 'adds travel in middle of term' 
        add_other_travels
        Travel.count.should > 0
        Travel.all.each do |trip|
          conditions = "start_date < ? AND end_date > ?"
          trip.member.field_terms.where(conditions, trip.date, trip.return_date).should_not be_nil
        end            
      end
    
    end # describe travel records    

    describe 'field_terms' do
    
      before(:each) do
        add_some_singles(10)
        add_some_couples(10)
      end
      
      it 'adds some field terms' do
        add_some_field_terms
        FieldTerm.count.should > 0
      end
    
    end # describe field terms
    
  end # 'It makes a dataset'
end


