include ApplicationHelper

describe Member do
  before(:each) do
    @status = Factory(:status)
    @family = Factory(:family, :status=> @status)
    @head = @family.head
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

  it "has the right 'unspecified' defaults when created" do
    m = Member.new
    m.bloodtype_id.should == 999999
    m.country_id.should == 999999
    m.status_id.should == 999999
    m.ministry_id.should == 999999
    m.education_id.should == 999999
    m.employment_status_id.should == 999999
    m.location_id.should == 999999
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
    Factory(:city)
    @location = Factory(:location)
    @family = Factory(:family, :status=>@status, :location=>@location)
    @member = new_family_member
    @member.last_name.should == @family.last_name
    @member.status.should == @family.status
    @member.location.should == @family.location
    
  end
  
  it "does not copy inherited fields from family when NOT new" do
    new_last_name = "something else"
    new_status = Factory(:status)
    city=Factory(:city)
    new_location = Factory(:location)
    @member.update_attributes(:status=>new_status, :location=>new_location, :last_name=>new_last_name)
    retrieved = Member.find(@member.id)  # re-read record from DB or at least cache
    retrieved.last_name.should == new_last_name
    retrieved.status.should == new_status
    retrieved.location.should == new_location
  end

  it 'male_female reports sex as :male if male' do
    @head.update_attribute(:sex,'M')
    @head.male_female.should == :male
  end  

  it 'male_female reports sex as :female if female' do
    @head.update_attribute(:sex,'F')
    @head.male_female.should == :female
  end  
  
  it 'male_female reports sex as nil if neither male nor female' do
    @head.update_attribute(:sex,'')
    @head.male_female.should be_nil
  end  

  describe "marrying: " do

    before(:each) do
      @head.update_attributes(:sex=>'M', :birth_date=>Date.new(1980,1,1))
      @man = @head
      @woman = Factory(:member, :sex=>"F", :birth_date=>Date.new(1980,1,1))
    end

    describe "by setting spouse_id" do

      it "can marry single person of opposite sex by setting spouse_id" do
        @man.update_attributes(:spouse_id=>@woman.id) # The 'marriage'
        @woman.reload  # since the database copy has been linked to spouse, but not local copy
        @woman.spouse.should == @man
        @man.spouse.should == @woman
      end

      it "cannot marry married person" do
        # Set up a married couple
        married_man = Factory(:member, :sex=>"M")
        married_woman = Factory(:member, :sex=>"F")
        married_woman.marry(married_man).should == married_man # This is just normal, valid, marriage to set up test
        # Single should not be able to marry married person
        @man.update_attributes(:spouse_id=>married_woman.id) # attempted 'marriage'
        @man.errors[:spouse].should include "proposed spouse is already married"
      end

      it "cannot marry single person of same sex" do
        @man.update_attribute(:sex, "F")
        another_woman = @man  # just a way of getting a woman without creating a new database record
        @woman.update_attributes(:spouse_id=>another_woman.id) # The 'marriage'
        @woman.errors[:spouse].should include "spouse can't be same sex" 
      end
      
      it "cannot marry underage person" do
        @woman.update_attributes(:birth_date=> Date.yesterday)
        @man.update_attributes(:spouse_id=>@woman.id) # The 'marriage'
        @man.errors[:spouse].should include "spouse not old enough to be married" 
      end
 
    end # by setting spouse_id
    
    describe "by using 'marry' method" do
          
      it "can marry single person of opposite sex (with marry method)" do
        @man.marry(@woman).should == @man # since successful marriage returns husband's object
        @woman.spouse.should == @man
        @man.spouse.should == @woman
      end       

      it "cannot marry married person" do
        # Set up a married couple
        married_man = Factory(:member, :sex=>"M")
        married_wife = Factory(:member, :sex=>"F")
        married_wife.marry(married_man).should == married_man # This is just normal, valid, marriage to set up test
        # Single should not be able to marry married person
        @woman.marry(married_man).should be_nil
        married_man.marry(@woman).should be_nil
        married_man.spouse.should == married_wife  # making sure it wasn't changed or dropped along the way
        @woman.spouse.should be_nil
      end
        
      it "cannot marry single person of same sex" do
        @man.update_attribute(:sex, "F")
        another_woman = @man  # just a way of getting a woman without creating a new database record
        @woman.marry(another_woman).should be_nil
        @woman.spouse.should be_nil
        another_woman.spouse.should be_nil
      end
      
      it "cannot marry underage person" do
        @woman.update_attributes(:birth_date=> Date.yesterday)
        @man.marry(@woman).should be_nil
      end
    end
  end # describe marrying  
end

