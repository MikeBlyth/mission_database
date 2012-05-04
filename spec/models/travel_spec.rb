include SimTestHelper

describe Travel do

  before(:each) do
    @object = Factory.build(:travel)
    @travel = @object
    @attr = @object.attributes
  end
  
  it "is valid with factory attributes" do
    @object.should be_valid
  end
  
  it "is not valid without a date" do
    @object.date = nil
    @object.should_not be_valid
  end
  
  it {finds_recent(Travel)}

  describe "with guest travelers" do

    before(:each) do
      @object.member_id = nil
      @guest_name = "Guest passenger"
      @object.other_travelers = @guest_name
    end      

    it "is valid with no member_id but with other travelers" do
      @object.should be_valid
    end
    
    it "is not valid with no member_id and no other travelers" do
      @object.other_travelers = ''
      @object.should_not be_valid
      @object.errors[:member].should_not be_nil
    end

    it "creates a virtual member when there is no member_id" do
      @object.traveler.should_not be_nil
    end

    it "returns name of single guest traveler as name" do
      @object.traveler.full_name.should == @guest_name 
    end  
    
    it "returns name of first of >1 guest travelers as name" do
      @object.other_travelers = @guest_name + "; Second Guest"
      @object.traveler.full_name.should == @guest_name 
    end  
    
    it "parses the name correctly" do
      @object.other_travelers = "Hill, Jack K."
      @object.traveler.full_name.should == "Jack K. Hill"
    end

  end # with guest travelers

  describe "travelers method gives names" do
    before(:each) do 
      @member = Factory.stub(:member)
    end
    
    it "lists individual's name" do
      @object.member = @member
      @object.travelers.should == "#{@member.short} #{@member.last_name}"
    end

    it "lists individual & spouse's names" do
      @object.member = @member
      wife = Factory.stub(:female, :spouse=>@member, :family=>@member.family)
      @member.spouse = wife      
      @object.with_spouse = true
      @object.travelers.should == "#{@member.short} & #{wife.short} #{@member.last_name}"
    end
    
    it "lists individual & 'spouse' if spouse not in database" do
      @object.member = @member
      @object.with_spouse = true
      @object.travelers.should == "#{@member.short} & spouse #{@member.last_name}"
    end
    
    it "ignores 'with_spouse' if there is no member as traveler" do
      @object.member = nil
      @object.with_spouse = true
      @object.other_travelers = "New Mexico team: Bob & Larry"
      @object.travelers.should == @object.other_travelers
    end
    
    it "ignores 'with_children' if there is no member as traveler" do
      @object.member = nil
      @object.with_children = true
      @object.other_travelers = "New Mexico team: Bob & Larry"
      @object.travelers.should == @object.other_travelers
    end
    
    it "lists individual & 'kids'" do
      @object.member = @member
      @object.with_children = true
      @object.travelers.should == "#{@member.short} #{@member.last_name} w kids"
    end
    
    it "lists individual & spouse's names & 'kids'" do
      @object.member = @member
      wife = Factory.stub(:female, :spouse=>@member, :family=>@member.family)
      @member.spouse = wife      
      @object.with_spouse = true
      @object.with_children = true
      @object.travelers.should == "#{@member.short} & #{wife.short} #{@member.last_name} w kids"
    end

    it "lists individual and other travelers" do
      @object.member = @member
      @object.other_travelers = "New Mexico team: Bob & Larry"
      @object.travelers.should == 
        "#{@member.short} #{@member.last_name}, with #{@object.other_travelers}"
    end

    it "other travelers when no member" do
      @object.member = nil
      @object.other_travelers = "New Mexico team: Bob & Larry"
      @object.travelers.should == @object.other_travelers
    end

  end # describe "travelers method gives names"

  describe "time filters" do
    before(:each) do
      @previous = Factory(:travel, :date=>Date.today-1.year, 
      :return_date=>Date.today-11.months)
      @current = Factory(:travel, :date=>Date.today-1.week, 
      :return_date=>Date.today+1.months)
      @future = Factory(:travel, :date=>Date.today+1.week, 
      :return_date=>Date.today+1.months)
      @far_future = Factory(:travel, :date=>Date.today+6.months, 
      :return_date=>Date.today+1.year)
      @current_no_return = Factory(:travel, :date=>Date.today-1.week, 
      :return_date=>nil)
    #  Travel.stub(:where).and_return [@previous, @current, @future, @far_future, @current_no_return]
    end
    
    it 'pending includes near-future trip only' do
      Travel.pending.should == [@future] 
    end

    it 'current includes only current trip with a return date' do
      Travel.current.should == [@current]
    end
    
  end # time filters
  
  describe "current_visitors" do
    before(:each) do
      @on_field = Factory(:status)
      @member=Factory.build(:member_without_family, :status=>Factory(:status_home_assignment))
      @travel.member=@member
      @travel.date = Date.today - 10.days
    end
    
    it 'includes member "on leave" coming to the field' do
      @member.save
      @travel.save
      current_visitors = Travel.current_visitors
      current_visitors.should_not be_empty
      current_visitors[0][:names].should match @member.last_name
    end

    it 'does not include member "on field" coming to the field' do
      @member.status=@on_field
      @member.save
      @travel.save
      Travel.current_visitors.should be_empty
    end

    it 'includes visitors but not on-field member when arriving together' do
      @member.status=@on_field
      @travel.other_travelers = 'Santa Claus'
      @member.save
      @travel.save
    #  puts Travel.current_visitors
      Travel.current_visitors.should_not be_empty
      visitors = Travel.current_visitors[0][:names]
      visitors.should match 'Santa Claus'
      visitors.should_not match @member.last_name
    end

    it 'does not include member "on leave" leaving the field' do
      @member.save
      @travel.arrival = false
      @travel.save
      Travel.current_visitors.should be_empty
    end

    it 'includes "other traveler" arriving on field' do
      @travel.other_travelers = 'Grandma'
      @travel.save
      current_visitors = Travel.current_visitors
      current_visitors.should_not be_empty
      current_visitors.map{|c| c[:names]}.include?('Grandma').should == true
    end

    it 'includes phone number of member "on leave" coming to the field' do
      @member.save
      contact=Factory(:contact, :member=>@member)
      @travel.save
      current_visitors = Travel.current_visitors
      current_visitors.should_not be_empty
      current_visitors[0][:contacts].should =~ regexcape(contact.phone_1.phone_format)
    end
    
    it 'does not include anyone who has already returned' do
      @member.save
      @travel.save
      travel2 = Factory(:travel, :member=>@member, :arrival=>false, :date=>Date.yesterday)
      Travel.current_visitors.should be_empty
    end
    
  end # current_visitors      

  describe 'current arrivals' do
    before(:each) do
      @member=Factory.build(:member_without_family)
      @travel.member=@member
      @travel.date = Date.today - 100
    end
    
    it 'includes person who has arrived but not departed' do
      @member.save
      @travel.save
      Travel.current_arrivals.should_not be_empty
      Travel.current_arrivals[0].member.should == @member
    end
    
    it 'includes person who has arrived but departs today' do
      @member.save
      @travel.save
      travel2 = Factory(:travel, :member=>@member, :arrival=>false, :date=>Date.today)
      Travel.current_arrivals.should_not be_empty
      Travel.current_arrivals[0].member.should == @member
    end
    
    it 'does not includes person who has arrived and departed' do
      @member.save
      @travel.save
      travel2 = Factory(:travel, :member=>@member, :arrival=>false, :date=>Date.yesterday)
      Travel.current_arrivals.should be_empty
    end

    it 'does not includes person who has not arrived' do
      @member.save
      # @travel.save - this person hasn't arrived!
      travel2 = Factory(:travel, :member=>@member, :arrival=>false, :date=>Date.yesterday)
      Travel.current_arrivals.should be_empty
    end
    
    it 'includes non-database person who has arrived but not departed' do
      @travel.member = nil;
      @travel.other_travelers = 'Santa Claus';
      @travel.save
      Travel.current_arrivals.should_not be_empty
    end
    
    it 'does not include non-database person who has arrived and departed' do
      @travel.member = nil;
      @travel.other_travelers = 'Santa Claus';
      @travel.save
      travel2 = Factory(:travel, :member=>nil, :other_travelers=>'Santa Claus', :arrival=>false, :date=>Date.yesterday)
      Travel.current_arrivals.should be_empty
    end
    
  end

  describe 'relates to field_terms:' do
    before(:each) do
      @member=Factory.stub(:member_without_family)
      @previous_term = Factory.stub(:field_term, :member=>@member,
           :start_date=>Date.today-600, :end_date=>Date.today-250)
      @current_term = Factory.stub(:field_term, :member=>@member,
           :start_date=>Date.today-200, :end_date=>Date.today+30)
      @future_term = Factory.stub(:field_term, :member=>@member,
           :start_date=>Date.today+100, :end_date=>nil)
      @far_future_term = Factory.stub(:field_term, :member=>@member,
           :start_date=>Date.today+300, :end_date=>nil)
      @member.stub(:field_terms).and_return [@previous_term, @current_term, @future_term, @far_future_term]
    end
    
    describe 'finds right existing field_term that is not yet linked:' do
      before(:each) do
        @travel=Factory.stub(:travel, :member=>@member, :arrival=>true, :date=>Date.today+100.days)
      end
    
      it 'nearest beginning of term if travel is arrival' do
        @travel.existing_term.should == @future_term
      end
      
      it 'current term if arrival near beginning of it' do
        @travel.date = @current_term.start_date + 60
        @travel.existing_term.should == @current_term    
      end
      
      it 'nearest end of term if travel is departure' do
        @travel.arrival = false
        @travel.existing_term.should == @current_term
      end
      
      it 'nil if departure date not near any end of term' do
        @travel.arrival = false
#        @current_term.destroy
      @member.stub(:field_terms).and_return [@previous_term, @future_term, @far_future_term]
        @travel.existing_term.should == nil
      end
      
      it 'nil if arrival date not near start of any term' do
#        @future_term.destroy
      @member.stub(:field_terms).and_return [@previous_term, @current_term, @far_future_term]
        @travel.existing_term.should == nil
      end
      
    end  # finds right field_term that is not yet linked
    
  end
  
  describe 'traveler array function parses passenger names' do
    
    it 'gives member id (not name) if the only passenger' do
      @travel.traveler_array.should == [@travel.member.id]
    end
    
    it 'gives only name of single other_traveler when no member specified' do
      @travel.member = nil
      @travel.other_travelers = 'Santa Claus'
      @travel.traveler_array.should == ['Santa Claus']
    end

    it 'gives member id plus name of other_traveler' do
      @travel.other_travelers = 'Santa Claus'
      @travel.traveler_array.should == [@travel.member.id,'Santa Claus']
    end

    it 'gives member id plus name of other_traveler' do
      @travel.other_travelers = 'Santa Claus'
      @travel.traveler_array.should == [@travel.member.id,'Santa Claus']
    end

    it 'handles various combinations of names for other travelers' do
      @travel.other_travelers = 'Santa & Mrs. Claus'
      @travel.traveler_array.should == [@travel.member.id,'Santa Claus', 'Mrs. Claus']
      @travel.other_travelers = 'Santa and Mrs. Claus'
      @travel.traveler_array.should == [@travel.member.id,'Santa Claus', 'Mrs. Claus']
      @travel.other_travelers = 'Santa Claus & Mrs. Elf'
      @travel.traveler_array.should == [@travel.member.id,'Santa Claus', 'Mrs. Elf']
      @travel.other_travelers = 'Santa & Mrs. Claus; Rudolph Reindeer'
      @travel.traveler_array.should == [@travel.member.id,'Santa Claus', 'Mrs. Claus', 'Rudolph Reindeer']
    end

    it 'includes spouse name if "with spouse" is specified' do
      create_spouse(@travel.member)
      @travel.with_spouse = true
      @travel.traveler_array.should == [@travel.member.id, @travel.member.spouse.id]
    end
  end
  
  describe 'current_travel_status_hash finds on- off-field status of each person' do

    before(:each) do 
      @travel.date = Date.today
      @member = @travel.member
      @prior_departure = Factory.build(:travel, :member=>@member, :date => Date.yesterday, 
          :arrival => false)
      @prior_arrival = Factory.build(:travel, :member=>@member, :date => Date.yesterday, 
          :arrival => true)
    end
    
    it 'shows arrival as true when latest travel of member is true' do
      @travel.arrival = true
      @travel.save
      # Create OLDER record which should be ignored in favor of newer one
      @prior_departure.save
  #    puts Travel.current_travel_status_hash
      Travel.current_travel_status_hash[@member.id][:arrival].should == @travel.arrival
    end

    it 'shows arrival as false when latest travel of member is true' do
      @travel.arrival = false
      @travel.save
      # Create OLDER record which should be ignored in favor of newer one
      @prior_arrival.save
  #    puts Travel.current_travel_status_hash
      Travel.current_travel_status_hash[@member.id][:arrival].should == @travel.arrival
    end

    it 'shows date of latest travel' do
      @travel.arrival = false
      @travel.save
      # Create OLDER record which should be ignored in favor of newer one
      @prior_arrival.save
   #   puts Travel.current_travel_status_hash
      Travel.current_travel_status_hash[@member.id][:date].should == @travel.date
    end

    describe 'when using with_spouse field' do

      before(:each) do
        create_spouse(@travel.member)
        @spouse = @travel.member.spouse
      end

      it 'arrival is true when arrived as spouse' do
        @travel.with_spouse = true
        @travel.arrival = true
        @travel.save
        # Create OLDER record which should be ignored in favor of newer one
        @prior_departure.with_spouse = true
        @prior_departure.save
   #     puts Travel.current_travel_status_hash
        Travel.current_travel_status_hash[@spouse.id][:arrival].should == @travel.arrival
      end

      it 'arrival is true when arrived as spouse and later member departs alone' do
        @travel.with_spouse = false  # Primary member is traveling alone
        @travel.arrival = false  # departing, leaving spouse in country
        @travel.save
        # Create OLDER record with couple arriving together
        @prior_arrival.with_spouse = true
        @prior_arrival.save
  #      puts Travel.current_travel_status_hash
        Travel.current_travel_status_hash[@spouse.id][:arrival].should == true
      end

      it 'arrival is false when arrived alone and later departs with spouse status' do
        husband = @travel.member
        wife = @spouse
        # First, wife arrives alone
        @prior_arrival.member = wife
        @prior_arrival.with_spouse = false
        @prior_arrival.save
        # Now husband and wife depart together under husband's name
        @travel.with_spouse = true  # spouse is traveling alone
        @travel.arrival = false  # departing, leaving spouse in country
        @travel.save
#        puts Travel.current_travel_status_hash
        Travel.current_travel_status_hash[@spouse.id][:arrival].should == false
      end
    end # when using spouse field

    describe 'when using other_travelers field' do
      
      before(:each) do
        @travel.other_travelers = 'Santa & Mrs. Claus'
      end
      
      it 'arrival is true when arrived with member and later member departs alone' do
        @travel.other_travelers = nil  # Primary member is traveling alone
        @travel.arrival = false  # departing, leaving spouse in country
        @travel.save
        # Create OLDER record with couple arriving together
        @prior_arrival.other_travelers = 'Santa & Mrs. Claus'
        @prior_arrival.save
  #      puts Travel.current_travel_status_hash
        Travel.current_travel_status_hash['Santa Claus'][:arrival].should == true
        Travel.current_travel_status_hash['Mrs. Claus'][:arrival].should == true
        Travel.current_travel_status_hash[@member.id][:arrival].should == false
      end
      
      it 'arrival is true when visitor arrived along with a member' do
        @travel.arrival = true
        @travel.save
        @prior_departure.other_travelers = 'Santa & Mrs. Claus'
        @prior_departure.save
   #     puts Travel.current_travel_status_hash
        Travel.current_travel_status_hash['Santa Claus'][:arrival].should == true
        Travel.current_travel_status_hash['Mrs. Claus'][:arrival].should == true
        Travel.current_travel_status_hash[@member.id][:arrival].should == true
      end
      
      it 'visitors in group maintain their separate arrival and departure statuses' do
        @travel.other_travelers = 'Person 2; Person 3'
        @travel.arrival = false  # departing, leaving spouse in country
        @travel.save
        @prior_arrival.other_travelers = 'Person 1; Person 2; Person 3'
        @prior_arrival.save
  #      puts Travel.current_travel_status_hash
        Travel.current_travel_status_hash['Person 1'][:arrival].should == true
        Travel.current_travel_status_hash['Person 1'][:date].should == @prior_arrival.date
        Travel.current_travel_status_hash['Person 2'][:arrival].should == false
        Travel.current_travel_status_hash['Person 2'][:date].should == @travel.date
      end
      
    end # when using other_travelers field
  end # current_travel_status_hash
end
