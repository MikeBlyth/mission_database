require 'spec_helper'
include SimTestHelper

describe Family do
  before(:each) do
    @family= Factory.build(:family)
    @head = @family.head
  end    

  it "is valid with valid attributes" do
    @family.should be_valid
  end

  it "is not valid without a first name" do
    @family.first_name = ''
    @family.should_not be_valid
  end

  it "is not valid without a last name" do
    @family.last_name = ''
    @family.should_not be_valid
  end
  it "is valid without a full name" do   # because set_indexed_name_if_empty is called before validation
    @family.name = ''
    @family.should be_valid 
  end

  it "is valid if name is unique" do
    @family.save # save the already-created family
    new_f = Factory.build(:family)
    new_f.name = "dummy name"
    new_f.should be_valid
  end

  def should_reject_duplicate(dup_column, unique_columns)
    @family.send(dup_column.to_s + "=", "9999")
    @family.save   # prime the situation by saving one member
    @family = Factory.build(:family)    # get another w same params (unless @family was changed before being called)
    unique_columns.each {|col| @family.send(col.to_s+"=", "7070") } # these fields are now unique
    @family.send(dup_column.to_s + "=", "9999")  # this field is a duplicate
    @family.valid?
    @family.errors[dup_column].should be_true
  end

  it "is invalid if name is duplicate" do
    should_reject_duplicate(:name, [:sim_id])
  end

  it "is invalid if new and name matches existing member" do
    @family.save
    @family.update_attribute(:name, "Any name")  # So we test dup head name, not family name
    @new_family = Factory.build(:family, :name=>@family.head.name)
    @new_family.valid?
    @family.errors[:name].should be_true    # ie there is an error against Name
  end

  it "is invalid if SIM ID already exists in database" do
    should_reject_duplicate(:sim_id, [:name])
  end

  it "creates a corresponding family head in the members table" do
    city=Factory.create(:city)
    @family.residence_location = Factory.create(:location)
    @family.status = Factory.create(:status)
    @family.save!    # has to be saved in order to create the member
    head = @family.head
    head.family_head.should be true
    head.family.should == @family
    head.name.should == @family.name
    head.status.should == @family.status
    head.residence_location.should == @family.residence_location
  end
  
  it "can be deleted when it contains no members" do
    @family.save!    # automatically saves first member (family head) also
    Family.count.should == 1        
    fam_member = @family.head # save it so we can destroy it :-)
    @family.head = nil        # because we can't destroy head if it is the family head
    fam_member.destroy    
    @family.destroy
    Family.count.should == 0        
  end

  it "can be deleted while it contains spouse" do
    @family.save!
    head = @family.head
    Family.count.should == 1
    Member.count.should == 1
    spouse = Factory(:member, :family=>@family, :spouse=> head, :sex=>head.other_sex)
    @family.destroy
    Family.count.should == 0
    Member.count.should == 0
  end

  describe "children list" do

    before(:each) do
      @children_ages = [1,2,3,4]
      @family.save!
      @children_names = []
      @children_ages.each do |age| 
        c = Factory(:child, :family_id => @family.id, :birth_date => Date::today-age.years)
        @children_names << c.first_name
      end  
      @children_names.reverse! # now they are sorted by age with oldest first
    end  

    it "returns a list of children" do
      @family.children.count.should == @children_ages.count
    end
       
    it "sorts the list of children by age" do
      last_birth_date = Date.new(1900,1,1)
      @family.children.each do |c|
        c.birth_date.should > last_birth_date
        last_birth_date = c.birth_date
# puts "**** Child=#{c.first_name}, #{c.birth_date}"
      end
    end

    it "returns a list of children's names" do
      @family.children_names.should == @children_names
    end

  end # children list

  describe "helpers" do
  
    before(:each) do
      # Just rename for convenience
      @family.save # since for the top level default, it's built but not saved so has no id
      @wife = @family.head
      @husband = Factory(:member, :family_id => @family.id, :sex => 'M', :spouse_id => @wife_id)
      @wife.update_attributes(:sex => 'F', :spouse_id => @husband.id)
    end  
      
    it 'returns the husband and wife' do
      @family.husband.should == @husband
      @family.wife.should == @wife
    end
    
    it 'returns the couple in husband/wife order' do
      @family.couple.should == [@husband, @wife]
    end
    
    it 'returns nil for husband/wife of single person' do
      @family = Factory(:family)
      @family.husband.should be_nil
      @family.wife.should be_nil
    end

  end # helpers  

  describe "reports current location" do
    before(:each) do
      @head = create_couple
      @family = @head.family
      @spouse = @head.spouse
    end    
    
    it "of single member" do
      # This creates a Fake of sorts so that we can define the current_location & _hash of members
      # without having to set up all the travel, status, and so on.
      # We do this because Family.current_location uses Member.current_location and not the base data,
      # and we test Member.current_location separately. As it stands, we have to do the method 
      # overrides for each example ... is there a simpler way?
      class Member
        def current_location_hash
          return {:residence=>'Home', :work=>'work'}
        end
        def current_location
          return "Home (work)"
        end
      end
      @head.spouse = nil  # before(:each) creates couple, so must make single for test
      @family.current_location.should == @head.current_location
      @family.current_location_hash.should == @head.current_location_hash
    end

    it "of couple when identical" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :work=>'work', :temp=>'temp', :travel=>'travel'}
        end
      end
      @family.current_location_hash.should == @head.current_location_hash
    end

    it "of couple when work is different" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :work=>'his_work'} if self.male?
          return {:residence=>'Home', :work=>'her_work'}
        end
      end
      @family.current_location_hash[:residence].should == 'Home'
      @family.current_location_hash[:work].should == 'his_work/her_work'
    end

    it "of couple when travel is the same" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :travel=>'their_travel'}
        end
      end
      @family.current_location_hash[:travel].should == 'their_travel'
    end

    it "of couple when travel is different" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :travel=>'his_travel'} if self.male?
          return {:residence=>'Home', :travel=>'her_travel'}
        end
      end
      @family.current_location_hash[:travel].should =~ Regexp.new("#{@head.short_name}.*his_travel.*#{@spouse.short_name}.*her_travel")
    end

    it "of couple when only wife travels" do
      class Member
        def current_location_hash
          return {:residence=>'Home'} if self.male?
          return {:residence=>'Home', :travel=>'her_travel'}
        end
      end
      @family.current_location_hash[:travel].should =~ Regexp.new("^#{@spouse.short}.*her_travel$")
    end

    it "of couple when only husband travels" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :travel=>'his_travel'} if self.male?
          return {:residence=>'Home'}
        end
      end
      @family.current_location_hash[:travel].should =~ Regexp.new("^#{@head.short}.*his_travel$")
    end

    it "of couple when temp_location the same" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :temp=>'their_temp'}
        end
      end
      @family.current_location_hash[:temp].should == 'their_temp'
    end

    it "of couple when temp_location different" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :temp=>'his_temp'} if self.male?
          return {:residence=>'Home', :temp=>'her_temp'}
        end
      end
      @family.current_location_hash[:temp].should =~ Regexp.new("#{@head.short}.*his_temp.*#{@spouse.short}.*her_temp")
    end

    it "of couple when only wife has temp_location" do
      class Member
        def current_location_hash
          return {:residence=>'Home'} if self.male?
          return {:residence=>'Home', :temp=>'her_temp'}
        end
      end
      @family.current_location_hash[:temp].should =~ Regexp.new("^#{@spouse.short}.*her_temp$")
    end

    it "of couple when only husband has temp_location" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :temp=>'his_temp'} if self.male?
          return {:residence=>'Home'}
        end
      end
      @family.current_location_hash[:temp].should =~ Regexp.new("^#{@head.short}.*his_temp$")
    end

  end
end

