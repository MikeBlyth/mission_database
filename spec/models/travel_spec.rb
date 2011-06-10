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
      current_visitors[0][:names].should =~ Regexp.new(@member.last_name)
    end

    it 'does not include member "on field" coming to the field' do
      @member.status=@on_field
      @member.save
      @travel.save
      Travel.current_visitors.should be_empty
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
      current_visitors[0][:names].should =~ /Grandma/
    end

    it 'includes phone number of member "on leave" coming to the field' do
      @member.save
      contact=Factory(:contact, :member=>@member)
      @travel.save
      current_visitors = Travel.current_visitors
      current_visitors.should_not be_empty
      current_visitors[0][:contacts].should =~ regexcape(contact.phone_1.phone_format)
    end

    
    
  end # current_visitors      
end
