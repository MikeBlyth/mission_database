describe Travel do

  before(:each) do
    @object = Factory.build(:travel)
    @attr = @object.attributes
  end
  
  it "is valid with factory attributes" do
    @object.should be_valid
  end
  
  it "is not valid without a date" do
    @object.date = nil
    @object.should_not be_valid
  end
  
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
  
end
