require 'spec_helper'

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

  describe 'does basic validation' do
    
    it "is valid with valid attributes" do
      @member.should be_valid
      @member.child.should be_false
    end

    it "is not valid without a first name" do
      @member.first_name = ''
      @member.should_not be_valid
    end

    it "is not valid without a last name" do
      @member.last_name = ''
      @member.should_not be_valid
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

  describe 'creates associated records' do
    it '--health data' do
      @member.save
      HealthData.find_by_member_id(@member.id).should_not be_nil
    end
    it '--personnel data' do
      @member.save
      PersonnelData.find_by_member_id(@member.id).should_not be_nil
    end
  end

  describe 'inheritance: ' do
    it "copies inherited fields from family when new" do
      Factory(:city)
      @location = Factory(:location)
      @family = Factory(:family, :status=>@status, :residence_location=>@location)
      @member = new_family_member
      @member.last_name.should == @family.last_name
      @member.status.should == @family.status
      @member.residence_location.should == @family.residence_location
    end
    
    it "does not copy inherited fields from family when NOT new" do
      new_last_name = "something else"
      new_status = Factory(:status)
      city=Factory(:city)
      new_location = Factory(:location)
      @member.update_attributes(:status=>new_status, :residence_location=>new_location, :last_name=>new_last_name)
      retrieved = Member.find(@member.id)  # re-read record from DB or at least cache
      retrieved.last_name.should == new_last_name
      retrieved.status.should == new_status
      retrieved.residence_location.should == new_location
    end
  end

  describe 'handles sex field' do
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

    it 'returns "other sex"' do
      @head.update_attribute(:sex,'M')
      @head.other_sex.should == 'F'    
      @head.update_attribute(:sex,'F')
      @head.other_sex.should == 'M'    
      @head.update_attribute(:sex,nil)
      @head.other_sex.should be_nil    
    end
  end

  describe "names: " do

    before(:each) do
      @member.first_name = 'Katarina'
      @member.middle_name = 'Saunders'
      @member.last_name = 'Patterson'
      @member.short_name = 'Kate'
      @family.update_attribute(:last_name,'Patterson')
    end  
    
    it "handles various name forms when middle and short names present" do
      @member.indexed_name.should == 'Patterson, Katarina (Kate) S.'
      @member.short.should == 'Kate'
      @member.middle_initial.should == 'S.'
      @member.to_label.should == 'Patterson, Katarina'
      @member.full_name.should == 'Katarina Saunders Patterson'
      @member.full_name_short.should == 'Kate Patterson'
      @member.full_name_with_short_name.should == 'Katarina Saunders Patterson (Kate)'
      @member.last_name_first.should == 'Patterson, Katarina Saunders'
      @member.last_name_first(:initial=>true).should == 'Patterson, Katarina S.'
      @member.last_name_first(:short=>true).should == 'Patterson, Kate Saunders'
      @member.last_name_first(:paren_short=>true).should == 'Patterson, Katarina (Kate) Saunders'
      @member.last_name_first(:middle=>false).should == 'Patterson, Katarina'
      @member.last_name_first(:short=>true, :initial=>true).should == 'Patterson, Kate S.'
    end

    it "handles various name forms when short but not middle name is present" do
      @member.middle_name = nil
      @member.indexed_name.should == 'Patterson, Katarina (Kate)'
      @member.short.should == 'Kate'
      @member.middle_initial.should == nil
      @member.to_label.should == 'Patterson, Katarina'
      @member.full_name.should == 'Katarina Patterson'
      @member.full_name_short.should == 'Kate Patterson'
      @member.full_name_with_short_name.should == 'Katarina Patterson (Kate)'
      @member.last_name_first.should == 'Patterson, Katarina'
      @member.last_name_first(:initial=>true).should == 'Patterson, Katarina'
      @member.last_name_first(:short=>true).should == 'Patterson, Kate'
      @member.last_name_first(:paren_short=>true).should == 'Patterson, Katarina (Kate)'
      @member.last_name_first(:middle=>false).should == 'Patterson, Katarina'
      @member.last_name_first(:short=>true, :initial=>true).should == 'Patterson, Kate'
    end

    it "handles various name forms when middle but not short name is present" do
      @member.short_name = nil
      @member.indexed_name.should == 'Patterson, Katarina S.'
      @member.short.should == 'Katarina'
      @member.middle_initial.should == 'S.'
      @member.to_label.should == 'Patterson, Katarina'
      @member.full_name.should == 'Katarina Saunders Patterson'
      @member.full_name_short.should == 'Katarina Patterson'
      @member.full_name_with_short_name.should == 'Katarina Saunders Patterson'
      @member.last_name_first.should == 'Patterson, Katarina Saunders'
      @member.last_name_first(:initial=>true).should == 'Patterson, Katarina S.'
      @member.last_name_first(:short=>true).should == 'Patterson, Katarina Saunders'
      @member.last_name_first(:paren_short=>true).should == 'Patterson, Katarina Saunders'
      @member.last_name_first(:middle=>false).should == 'Patterson, Katarina'
      @member.last_name_first(:short=>true, :initial=>true).should == 'Patterson, Katarina S.'
    end

    it "name_optional_last suppresses last name when equal to family last name" do
      @member.name_optional_last.should == 'Kate S.'
    end
    
    it "name_optional_last includes last name when not equal to family last name" do
      @member.last_name = 'Smith'
      @member.name_optional_last.should == 'Kate S. Smith'
    end
    
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

    it "does not delete a still-married member" do
      @man.marry(@woman)
      lambda {@woman.destroy}.should_not change(Member, :count)
      @man.spouse.should == @woman
      @woman.errors.should_not be_empty
    end
    
    it "de-links spouse when its own spouse is set to nil" do
      # The member itself can't detect that the spouse has been changed, so the controller must
      # set the previous_spouse when this happens
      @man.marry(@woman)
      @man.previous_spouse = @woman   # This must be done by controller in real life
      @man.update_attributes(:spouse=>nil)
      @woman.spouse.should be_nil
    end      

    it "does not update spouse when prev spouse still links to it" do
      # I.e., can't change A's spouse from B to C if B still thinks he's married to A 
      # The member itself can't detect that the spouse has been changed, so the controller must
      # set the previous_spouse when this happens
      @man.marry(@woman)
      new_wife = Factory(:member, :sex=>'F')
      @man.previous_spouse = @woman   # This must be done by controller in real life
      @man.update_attributes(:spouse=>new_wife)
      @woman.spouse.should == @man  # still
      @man.errors.should_not be_empty
    end      

    it "handles missing spouse by resetting spouse_id" do
      @man.update_attribute(:spouse_id, 99999) # Note that this bypasses validation
      @man.reload.spouse.should == nil
    end

    it "unlinks spouse when a member is deceased" do
      deceased_status = Factory(:status, :code=>'deceased')
      @man.marry(@woman)
      @man.status = deceased_status
      @man.save
      @man.reload.spouse.should be_nil
      @woman.reload.spouse.should be_nil
    end
    
  end # describe marrying  

  describe "Handles scopes like 'active'" do
    pending 'rewrite the filtering mechanism'
  end

  describe "current location" do
    
    it "reports location of member with no status" do
      @residence = Factory(:location)
      @head.update_attributes(:status=>nil, :residence_location=> @residence)
      @head.reload.current_location.should =~ Regexp.new(@residence.description)
      @head.status.should be_nil
    end

    describe "visiting_field?" do
    
      before(:each) do
        @head.travels.create :date=>Date.yesterday, :arrival=>true
      end
        
      it "is true for someone with no status coming to field" do
        @head.update_attributes(:status=>nil)
        @head.visiting_field?.should == true
      end
      
      it "is true for someone with off-field status coming to field" do
        @head.status.update_attributes(:on_field=>false)
        @head.visiting_field?.should == true
      end
      
      it "is false for someone with off-field status with no travel" do
        @head.status.update_attributes(:on_field=>false)
        @head.travels.delete_all
        @head.visiting_field?.should == false
      end
      
      it "is false for someone with on-field status coming to field" do
        @head.status.update_attributes(:on_field=>true)
        @head.visiting_field?.should == false
      end
      
    end # visiting_field?

    describe 'residence_location' do

      it 'is shown as "?" if empty' do
        @head.residence_location = nil
        @head.current_location.should == '?'
      end
      
      it 'is shown as description if not empty' do
        @head.residence_location = Factory.build(:location)
        @head.current_location.should == @head.residence_location.description
      end
      
    end # 'residence_location'
    
    describe 'work_location' do

      it 'is not shown at all if empty' do
        @head.work_location = nil
        @head.current_location.should == '?'  # '?' for the residence_location
      end
      
      it 'is not shown if empty and :missing=>'' is used' do
        @head.residence_location = Factory.build(:location)
        @head.work_location = nil
        @head.current_location(:missing=>'').should == @head.residence_location.description  # '?' for the residence_location
      end
      
      it 'is not shown at all if same as residence_location' do
        @head.work_location = Factory.build(:location)
        @head.residence_location = @head.work_location
        @head.current_location.should == @head.residence_location.description
      end
      
      it 'is shown as description if not empty' do
        @head.work_location = Factory.build(:location)
        @head.current_location.should =~ Regexp.new("\\?.*#{@head.work_location.description}")
      end
      
    end # 'work_location'
    
    describe "temporary location" do
      before(:each) do
        @head.temporary_location = 'My Resort'
        @head.temporary_location_from_date = Date.yesterday
        @head.temporary_location_until_date = Date.yesterday
      end

      it 'is not shown at all if empty' do
        @head.temporary_location = nil
        @head.current_location.should_not =~ /My Resort/
      end

      it 'is not shown if past dates do not include today' do
        @head.current_location.should_not =~ /My Resort/
      end      

      it 'is not shown if future dates do not include today' do
        @head.temporary_location_from_date = Date.today + 2.days
        @head.temporary_location_until_date = Date.today + 2.days
        @head.current_location.should_not =~ /My Resort/
      end      

      it 'is shown if defined and dates include today' do
        @head.temporary_location_until_date = Date.today + 2.days
        @head.current_location.should =~ /My Resort/
      end

    end # Temporary Location

    describe 'travel location' do

      describe 'for on-field people departing' do

        before(:each) do
          @head.travels.create(:date=>Date.yesterday - 2.day, :return_date=>Date.yesterday - 2.days, :arrival=>false)
          @travel = @head.travels.first
        end
      
        it 'is shown for dates including today' do
          @travel.update_attributes(:return_date => Date.today + 2.days)
          @head.travel_location.should =~ /left|traveled|depart/i
          @head.travel_location.should =~ Regexp.new(@travel.date.to_s(:short))
        end
        
        it 'is nil for dates in past' do
          @head.travel_location.should be_nil
        end
        
        it 'is nil for dates in the future' do
          @travel.update_attributes(:date=>Date.tomorrow + 1.day, :return_date => Date.tomorrow + 2.days)
          @head.travel_location.should be_nil
        end
      end # 'for on-field people departing'      
      
      describe 'for off-field people arriving' do

        before(:each) do
          @head.travels.create(:date=>Date.yesterday - 2.day, :return_date=>Date.yesterday - 2.days, :arrival=>true)
          @travel = @head.travels.first
          @head.status.update_attributes(:on_field=>false)
        end
      
        it 'is shown for dates including today' do
          @travel.update_attributes(:return_date => Date.today + 2.days)
          @head.travel_location.should =~ /arriv/i
          @head.travel_location.should =~ Regexp.new(@travel.date.to_s(:short))
        end
        
        it 'is nil for dates in past' do
          @head.travel_location.should be_nil
        end
        
        it 'is nil for dates in the future' do
          @travel.update_attributes(:date=>Date.tomorrow + 1.day, :return_date => Date.tomorrow + 2.days)
          @head.travel_location.should be_nil
        end
      end # 'for off-field people departing'      
      
      describe 'for off-field people departing' do

        before(:each) do
          @head.travels.create(:date=>Date.yesterday - 2.day, :return_date=>Date.yesterday - 2.days, :arrival=>false)
          @travel = @head.travels.first
          @head.status.update_attributes(:on_field=>false)
        end
      
        it 'is not shown even for dates including today' do
          @travel.update_attributes(:return_date => Date.today + 2.days)
          @head.travel_location.should be_nil
        end
        
      end # 'for off-field people departing'      

      describe 'for on-field people arriving' do

        before(:each) do
          @head.travels.create(:date=>Date.yesterday - 2.day, :return_date=>Date.yesterday - 2.days, :arrival=>true)
          @travel = @head.travels.first
        end
      
        it 'is not shown even for dates including today' do
          @travel.update_attributes(:return_date => Date.today + 2.days)
          @head.travel_location.should be_nil
        end
        
      end # 'for on-field people arriving'      
      
    end # travel location
    
  end

end

