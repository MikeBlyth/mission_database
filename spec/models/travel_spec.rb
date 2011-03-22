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
end
