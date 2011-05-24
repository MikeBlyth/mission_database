require 'spec_helper'
include SimTestHelper

describe Family do
#  before(:each) do
#    @family= Factory(:family)
#    @head = Factory(:member, :family=>@family)
##    @family.update_attribute(:head, @head)
#    @family.stub(:head).and_return(@head)
#  end    

  describe 'basic validation' do
    before(:each) do
      @family= Factory.build(:family)
    end    

    it "is valid with valid attributes" do
      @family.should be_valid
    end

#    it { should validate_presence_of(:first_name) }
#    it { should validate_presence_of(:last_name) }
#    it { should_not validate_presence_of(:name) }

#    describe "uniqueness of name" do
#      before(:each) {Factory(:family)}
#      it { should validate_uniqueness_of(:name) }
#      it { should validate_uniqueness_of(:sim_id) }
#    end

    it "is not valid without a first name" do
      @family.first_name = ''
      @family.should_not be_valid
      @family.errors[:first_name].should_not be_nil
    end

    it "is not valid without a last name" do
      @family.last_name = ''
      @family.should_not be_valid
      @family.errors[:last_name].should_not be_nil
    end

    it "is invalid with duplicate name" do
      @family.save
      @new = Factory.build(:family, :name=>@family.name)
      @new.should_not be_valid
      @family.errors[:name].should_not be_nil
    end

    it "is invalid if new and name matches existing member" do
      # This is not a straight check for duplication, but checking whether the FAMILY.name
      # already exists as a MEMBER.name. 
      @other_member = build_member_without_family #has to be saved since method accesses database
      @other_member.save
      @family[:name] = @other_member.name
      @family.valid?
      @family.errors[:name].to_s.should =~ /already a member named/    # ie there is an error against Name
    end
  end # basic validation
  
  describe 'deletion protection:' do
    before(:each) {@family=Factory(:family)}

    it "can be deleted when it contains no members" do
      lambda {@family.destroy}.should change(Family, :count).by(-1)
    end

    it "can be deleted when it contains members" do
      lambda {@family.destroy}.should change(Family, :count).by(-1)
    end
  end # deletion protection

  describe "children list" do

    before(:each) do
      @family = Factory.stub(:family, :id=>1)
      @children_ages = [1,2,3,4]
      @children_names = []
      @children = []
      @children_ages.each do |age| 
        child = Factory(:child, :family=> @family, :birth_date => Date::today-age.years)
        @children_names << child.first_name
        @children << child
      end  
      @children_names.reverse! # now they are sorted by age with oldest first
      @children.reverse!
    end  

    it "sorts the list of children by age" do
      @family.children.should == @children
    end

    it "returns a list of children's names" do
      @family.children_names.should == @children_names
    end

  end # children list

  describe "husband, wife, couple helpers" do
  
    describe "for married couple" do
      before(:each) do
        @family=Factory.stub(:family)
        @wife = Factory.stub(:member, :sex=>'F', :family=>@family)
        @family.stub(:head).and_return(@wife)
        @husband = Factory.stub(:member, :family => @family, :sex => 'M', :spouse => @wife)
        @wife.stub(:spouse).and_return(@husband)
        @family.stub(:members).and_return([@wife, @husband])
      end  
        
      it 'returns the husband and wife' do
        @family.husband.should == @husband
        @family.wife.should == @wife
      end
      
      it 'returns the couple in husband/wife order' do
        @family.couple.should == [@husband, @wife]
      end
    end      
    
    describe "for single person" do
      it 'return nil' do
        @family = Factory.stub(:family)   # override the before_each setup of @family as a couple
        @family.husband.should be_nil
        @family.wife.should be_nil
      end
    end
    
  end # helpers  

  describe "employment helper" do
    it 'returns family_head employment status as its own' do
     @head = Factory.stub(:member)
     @personnel_data=Factory.stub(:personnel_data, 
          :member=>@head,
          :employment_status=>Factory.stub(:employment_status))
     @family = Factory.stub(:family, :head=>@head)
     @head.stub(:personnel_data).and_return(@personnel_data)
     @family.employment_status.should_not be_nil
     @family.employment_status.should == @family.head.employment_status
    end
  end


end

