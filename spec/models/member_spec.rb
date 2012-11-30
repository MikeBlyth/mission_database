require 'spec_helper'
include SimTestHelper

describe Member do

  def new_family_member
    Factory.build(:member, :family=>@family)
  end

  ## FOR DEBUGGING ONLY
  def puts_member(m, tag='member')
    puts "****+++ #{tag}: #{m.to_s}, id=#{m.id}, status_id=#{m.status_id}, family_id=#{m.family_id}"
  end  

  describe 'does basic validation' do
    before(:each) do
      @family = Factory.stub(:family)
      @head = Factory.stub(:member, :family=>@family)
      @member = new_family_member    # This is in addition to the family_head, which is *saved* on creation of a family
                              #   This second family member @member is *not* saved yet
    end    
    
    it "is valid with valid attributes" do
      @member.should be_valid
      @member.child.should be_false
    end

# Shoulda not working with CanCan
#    it { should validate_presence_of(:family) }
#    it { should validate_presence_of(:first_name) }
#    it { should validate_presence_of(:last_name) }

#    describe "uniqueness of name" do
#      before(:each) {Factory(:member, :family=>@family)}
#      it { should validate_uniqueness_of(:name) }
#    end

    it "is not valid without a first name" do
      @member.first_name = ''
      @member.should_not be_valid
      @member.errors[:first_name].should_not be_nil
    end

    it "is not valid without a last name" do
      @member.last_name = ''
      @member.should_not be_valid
      @family.errors[:last_name].should_not be_nil
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
      @member.family = nil
      @member.should_not be_valid
      @member.errors[:family].should_not be_nil
    end

  end # basic validation

  describe "deletion protect:" do
    before(:each) do
      @family = Factory(:family)
      @head = Factory(:member, :family=>@family)
      @family.update_attribute(:head, @head)
      @member = new_family_member    # This is in addition to the family_head, which is *saved* on creation of a family
                              #   This second family member @member is *not* saved yet
    end    

    it "cannot be deleted if it is the family head" do
      lambda{@head.destroy}.should_not change(Member, :count)
      @head.errors[:delete].should include "Can't delete head of family."
    end
   
    it "can be deleted if it is not the family head" do
      @member.save    # member is not the head
      lambda{@member.destroy}.should change(Member, :count).by(-1)
    end
  
  end # deletion protect

# This isn't needed, is it?
#  describe 'creates associated records' do
#    before(:each) do
#      @family = Factory.stub(:family)
#      @head = Member.new(:first_name=>'A', :name=>'A', :family => @family)
##  @head.should be_valid
##  @head.personnel_data.should_not be_nil
##      @head = mock(Member)
##      @head.should_receive(:save).and_return(true)
##      @head.stub(:id).and_return(100)
#    end    

#    it '--health data' do
#      lambda {@head.save}.should change(PersonnelData, :count).by(1)
#    end

#    it '--personnel data' do
#      lambda {@head.save}.should change(HealthData, :count).by(1)
#    end
#  end

  describe 'inheritance: ' do
    before(:each) do
      @location = Factory.stub(:location)
      @status = Factory.stub(:status)
      @family = Factory.stub(:family, :status=> @status, :residence_location=>@location)
   #   @head = @family.head
      @member = new_family_member    # This is in addition to the family_head, which is *saved* on creation of a family
                              #   This second family member @member is *not* saved yet
    end    

    it "copies inherited fields from family when new" do
      @member.last_name.should == @family.last_name
      @member.status.should == @family.status
      @member.residence_location.should == @family.residence_location
    end
    
    it "does not copy inherited fields from family when NOT new" do
      new_last_name = "something else"
      new_status = Factory(:status)
      city=Factory(:city)
      new_location = Factory(:location)
      @member.update_attributes(:status=>new_status, :last_name=>new_last_name)
      retrieved = Member.find(@member.id)  # re-read record from DB or at least cache
      retrieved.last_name.should == new_last_name
      retrieved.status.should == new_status
    end
  end # inheritance

  describe 'handles sex field' do
    before(:each) do
      @head = Member.new
    end    

    it 'male_female reports sex as :male if male' do
      @head.sex = 'M'
      @head.male_female.should == :male
    end  

    it 'male_female reports sex as :female if female' do
      @head.sex = 'F'
      @head.male_female.should == :female
    end  
    
    it 'male_female reports sex as nil if neither male nor female' do
      @head.sex = ''
      @head.male_female.should be_nil
    end  

    it 'returns "other sex"' do
      @head.sex = 'M'
      @head.other_sex.should == 'F'    
      @head.sex = 'F'
      @head.other_sex.should == 'M'    
      @head.sex = nil
      @head.other_sex.should be_nil    
    end
  end

  describe "names: " do
    before(:each) do
      @member = Member.new
      @member.first_name = 'Katarina'
      @member.middle_name = 'Saunders'
      @member.last_name = 'Patterson'
      @member.short_name = 'Kate'
 #     @family.update_attribute(:last_name,'Patterson')
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
      @family=Factory.stub(:family, :last_name=>@member.last_name)
      @member.family = @family
      @member.name_optional_last.should == 'Kate S.'
    end
    
    it "name_optional_last includes last name when not equal to family last name" do
      @family=Factory.stub(:family, :last_name=>@member.last_name)
      @member.family = @family
      @member.last_name = 'Smith'
      @member.name_optional_last.should == 'Kate S. Smith'
    end
    
    describe "'short' method (short or first name)" do
      
      it 'returns short_name when it exists' do
        @member.short.should == @member.short_name  # it's Katie by default in this testing
      end
      
      it 'returns first_name when short_name is nil' do
        @member.short_name = nil
        @member.short.should == @member.first_name
      end
      
      it 'returns first_name when short_name is empty string' do
        @member.short_name = ''
        @member.short.should == @member.first_name
      end
      
      it 'returns first_name when short_name is blanks' do
        @member.short_name = '  '
        @member.short.should == @member.first_name
      end
    end # short method (short or first name)
      
    
  end

  describe "marrying: " do
    before(:each) do
#      @family = Factory(:family)
      @man = Factory.build(:member, :birth_date=>Date.new(1980,1,1))
#      @family.update_attribute(:head, @man)
      @woman = Factory.build(:member, :sex=>"F", :birth_date=>Date.new(1980,1,1))
    end

    it "can marry single person of opposite sex (with marry method)" do
      @man.marry(@woman).should == @man # since successful marriage returns husband's object
      @woman.spouse.should == @man
      @man.spouse.should == @woman
    end       

    it "cannot marry married person" do
      @man.spouse = Factory.build(:member, :sex=>'F')
      @man.marry(@woman).should be_nil
      @man.errors[:spouse].first.should =~ /already married/
      @woman.marry(@man).should be_nil
      @woman.errors[:spouse].first.should =~ /already married/
    end
      
    it "cannot marry single person of same sex" do
      @man.sex = "F"
      @woman.marry(@man).should be_nil
    end
    
    it "cannot marry underage person" do
      @woman.birth_date= Date.yesterday
      @man.marry(@woman).should be_nil
      @man.errors[:spouse].first.should =~ /(not old enough) | (too young)/
      @woman.marry(@man).should be_nil
      @woman.errors[:spouse].first.should =~ /(not old enough) | (too young)/
    end

    it "handles a error during saving a spouse" do
      @woman.first_name = nil
      @man.marry(@woman).should be_nil
      @woman.errors[:first_name].should_not be_empty
    end        

    it "does not delete a still-married member" do
      @man.family = Factory.build(:family)
      @man.save
      @man.marry(@woman).should_not be_nil
      lambda {@woman.destroy}.should_not change(Member, :count)
      @man.spouse.should == @woman
      @woman.errors[:delete].should_not be_empty
    end
    
    it "unlinks spouse when a member is deceased" do
      deceased_status = Factory(:status, :code=>'deceased')
      @man.marry(@woman)
      @man.status = deceased_status
      @man.save!
      @man.reload.spouse.should be_nil
      @woman.reload.spouse.should be_nil
    end
    
  end # describe marrying  
  
  describe 'create wife' do
    before(:each) do
    end
    
    it 'creates a wife for a man' do
      @head = factory_member_create
      wife = @head.create_wife
      @head.spouse.should == wife
      wife.last_name.should == @head.last_name
      wife.family.should == @head.family
      wife.sex.should == 'F'
      wife.first_name.should == '(Mrs.)'
      wife.status.should == @head.status
      wife.residence_location.should == @head.residence_location
      wife.employment_status.should == @head.employment_status
    end
    
    it 'does not create a wife for a woman' do
      @head=factory_member_basic
      @head.update_attributes(:sex => 'F')
      @head.create_wife.spouse.should == nil
      @head.errors[:spouse].first.should =~ /same sex/
    end
    
    it 'uses specified parameters for wife' do
      @head=factory_member_basic
      @head.create_wife({:first_name=>'Mary'}).first_name.should == 'Mary'
    end
  end # Create wife

  describe "primary_contact" do
    before(:each) do
      @member=Factory(:member)
      @contact = Factory(:contact, :member=>@member)
    end
    
    it 'identifies contact record with is_primary==true' do
      @contact.save
      @member.primary_contact.should == @contact
    end

    it 'returns nil if no contact record has is_primary==true' do
      @contact.is_primary=false
      @contact.save
      @member.primary_contact.should be_nil
    end

    it "returns child's parent's primary_contact if child has none" do
      head = @member.family.head = Factory(:member, :family=>@member.family)
      @member.should_not == head # 'cause we'll use member as the child
      @member.stub(:child).and_return(true)
      @contact.member = head  # making contact belong to the family head
      @contact.save
      @member.primary_contact.should == @contact
    end

    it "returns spouse's primary_contact if member has none" do
      spouse = Factory.stub(:member, :spouse=>@member)
      @contact.save
      spouse.primary_contact.should == @contact
    end

    it "does not returns spouse's primary_contact if :no_substitution is set" do
      spouse = Factory.stub(:member, :spouse=>@member)
      @contact.save
      spouse.primary_contact(:no_substitution=>true).should be_nil
    end

    it "returns spouse's own contact if she has one" do
      spouse = Factory(:member, :spouse=>@member)
      @contact.save
      spouse_contact = Factory(:contact, :member=>spouse)
      spouse.primary_contact.should == spouse_contact
    end

  end

  describe "current location" do
    before(:each) do
      @status = Factory(:status)
      @family = Factory(:family, :status=> @status)
      @head = Factory(:member, :family=>@family)
      @family.update_attribute(:head, @head)
    end    
    
    it "reports location of member with no status" do
      @residence = Factory(:location)
      @head.family.update_attributes(:status=>nil, :residence_location=> @residence)
      @head.reload.current_location.should =~ Regexp.new(@residence.description)
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
        @head.family.residence_location = nil
        @head.current_location.should == '?'
      end
      
      it 'is shown as description if not empty' do
        @head.family.residence_location = Factory.build(:location)
        @head.current_location.should == @head.residence_location.description
      end
      
    end # 'residence_location'
    
    describe 'work_location' do

      it 'is not shown at all if empty' do
        @head.work_location = nil
        @head.current_location.should == '?'  # '?' for the residence_location
      end
      
      it 'is not shown if empty and :missing=>'' is used' do
        @head.family.residence_location = Factory.build(:location)
        @head.work_location = nil
        @head.current_location(:missing=>'').should == @head.residence_location.description  # '?' for the residence_location
      end
      
      it 'is not shown at all if same as residence_location' do
        @head.work_location = Factory.build(:location)
        @head.family.residence_location = @head.work_location
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
      
        it 'date format' do
          Date.new(2099,12,25).to_s(:short).should_not =~ /99/
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

        it 'is shown for accompanying spouse' do
          @travel.update_attributes(:return_date => Date.today + 2.days, :with_spouse=>true)
          spouse = create_spouse(@head)
          spouse.travel_location.should =~ Regexp.new(@travel.date.to_s(:short))
        end

        it 'is not shown for non-accompanying spouse' do
          @travel.update_attributes(:return_date => Date.today + 2.days, :with_spouse=>false)
          spouse = create_spouse(@head)
          spouse.travel_location.should be_nil
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
        
        it 'is shown for accompanying spouse' do
          @travel.update_attributes(:return_date => Date.today + 2.days, :with_spouse=>true)
          spouse = create_spouse(@head)
          spouse.update_attribute(:status, @head.status)
          spouse.travel_location.should =~ Regexp.new(@travel.date.to_s(:short))
        end

        it 'is not shown for non-accompanying spouse' do
          @travel.update_attributes(:return_date => Date.today + 2.days, :with_spouse=>false)
          spouse = create_spouse(@head)
          spouse.travel_location.should be_nil
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
    
  end # current_location
  
  describe "dependent method" do

    before(:each) do
      @family = Factory.stub(:family)
      @husband = Factory.stub(:member, :last_name=>'Last', :first_name=>'Head', :family=>@family, :sex=>'M')
      @family.head = @husband
      @wife = Factory.stub(:member, :last_name=>'Last', :first_name=>'Wife', :family=>@family, :sex=>'F')
      @husband.spouse = @wife
      @wife.spouse = @husband
      @member = Factory(:member, :first_name=>'Member', :last_name=>'Last', :family => @family)
      @dep_mk = Factory(:employment_status, :code=>'mk_dependent')
      @adult_mk = Factory(:employment_status, :code=>'adult_mk')
    end
    
    it "is true for head of family" do
      @husband.dependent.should be_true
    end
    
    it "is true for spouse" do
      @husband.spouse.dependent.should be_true
    end
    
    it "is true for child" do
      @member.child = true
      @member.personnel_data = Factory(:personnel_data, :employment_status=>@dep_mk)
      @member.dependent.should be_true
    end
    
    it "is false for non-child non-spouse" do
      @member.child = false
      @member.personnel_data = Factory.build(:personnel_data, :employment_status=>@adult_mk)
      @member.dependent.should be_false
    end
    
    it "is true for unmarried head of family" do
      @husband.spouse = nil
      @husband.dependent.should be_true
    end
    
    it "is false for deceased child" do
      @member.child = true
      @deceased = Factory.stub(:status, :code=>'deceased')
      @member.status = @deceased
      @member.dependent.should be_false
    end      
    
  end  #dependent method

  describe "scopes or relations" do
    before(:each) do
      @field_status = Factory.build(:status, :on_field=>true, :active=>false)
      @active_status = Factory.build(:status, :on_field=>false, :active=>true)
      @active_field_status = Factory.build(:status, :on_field=>true, :active=>false)
      @neither_status = Factory.build(:status, :on_field=>true, :active=>false)
      @family = Factory(:family, :status=>nil) # need a place to put the members
    end  

    it "selects on_field members" do
      @field_status.save
      @active_status.save
      2.times do
        Factory(:member, :family=> @family, :status=>@field_status)
        Factory(:member, :family=> @family, :status=>@active_status)
      end
      Member.those_on_field.count.should == 2 
      Member.those_active.count.should == 2 
      Member.those_on_field.each do |m|
        m.on_field.should be_true
        m.active.should_not be_true
      end
      Member.those_active.each do |m|
        m.on_field.should_not be_true
        m.active.should be_true
      end
    end # selects on_field members
  end  

  describe 'finds members by name' do
    before(:each) do
      @member = Factory(:member)
      @member.update_attribute(:short_name, "Shorty")
    end

    it 'return empty array if name not found' do
      Member.find_with_name('stranger').should == []
    end

    it 'returns empty array if name blank' do
      Member.find_with_name('').should == []
    end

    it 'returns empty array if name nil' do
      Member.find_with_name(nil).should == []
    end


    it 'finds simple name' do  # searching for ONE of last name, first name, short name, full name
      Member.find_with_name(@member.first_name).should == [@member]
      Member.find_with_name(@member.last_name).should == [@member]
      Member.find_with_name(@member.name).should == [@member]
      Member.find_with_name(@member.short_name).should == [@member]
    end

    it 'finds "last_name, first_name"' do  # when this is different from stored full name (#name)
      @member.update_attribute(:name,"xxxx")  # since we're not relying on this
      Member.find_with_name("#{@member.last_name}, #{@member.first_name}").should == [@member]
    end
      
    it 'finds "last_name, short_name"' do  
      Member.find_with_name("#{@member.last_name}, #{@member.short_name}").should == [@member]
    end
      
    it 'finds "last_name, initial"' do  
      Member.find_with_name("#{@member.last_name}, #{@member.first_name[0]}").should == [@member]
    end
      
    it 'finds "first_name last_name"' do  
      Member.find_with_name("#{@member.first_name} #{@member.last_name}").should == [@member]
    end
      
    it 'finds "beginning_of_first_name beginning_of_last_name"' do  
      Member.find_with_name("#{@member.first_name[0..2]} #{@member.last_name[0..1]}").should == [@member]
    end
      
    it 'finds "beginning_of_first_name"' do  
      Member.find_with_name("#{@member.first_name[0..2]}").should == [@member]
    end
      
    it 'finds "beginning_of_short_name"' do  
      Member.find_with_name("#{@member.short_name[0..2]}").should == [@member]
    end
      
    it 'finds "beginning_of_last_name"' do  
      Member.find_with_name("#{@member.last_name[0..2]}").should == [@member]
    end

    it 'finds both members with last name' do
      spouse = create_spouse(@member)
      Member.find_with_name("#{@member.last_name}").include?(@member).should be_true
      Member.find_with_name("#{@member.last_name}").should include(spouse)
    end

    it 'finds both members with first name' do
      same_first = Factory(:member, :last_name=>'different', :first_name=>@member.first_name)
      Member.find_with_name("#{@member.first_name}").should include(@member)
      Member.find_with_name("#{@member.first_name}").should include(same_first)
    end

    it 'uses optional conditions' do
      spouse = create_spouse(@member)
      Member.find_with_name("#{@member.last_name}", ["sex=?", 'M']).should include(@member)
      Member.find_with_name("#{@member.last_name}", ["sex=?", 'M']).should_not include(spouse)
    end

    it 'excludes partial match to "last_name, different_short_name"' do  
      spouse = create_spouse(@member)
      Member.find_with_name("#{@member.last_name}, #{@member.short_name}").should == [@member]
        # == [@member] implies that spouse is not included
    end
      
    it 'excludes partial match to "same_short_name different_last_name"' do  
      other = Factory(:member)
      other.update_attribute(:short_name, @member.short_name)
      Member.find_with_name("#{@member.last_name}, #{@member.short_name}").should == [@member]
        # == [@member] implies that spouse is not included
    end
      
  end # finds members by name

  describe 'temp_location function' do
    before(:each) do
      @temploc = 'French Riviera'
      @member = Factory.build(:member, :temporary_location => @temploc, 
        :temporary_location_from_date => Date.today - 1.day, 
        :temporary_location_until_date => Date.today + 1.day
        )
    end
    
    it 'returns nil before travel' do
      @member.temporary_location_from_date = Date.tomorrow
      @member.temp_location.should == nil
    end

    it 'returns nil after travel' do
      @member.temporary_location_from_date = Date.today - 10.days
      @member.temporary_location_until_date = Date.today - 5.days
      @member.temp_location.should == nil
    end

    it 'returns value if start date is blank and end is in the future' do
      @member.temporary_location_from_date = nil
      @member.temp_location.should match @temploc
    end

    it 'returns value if start date is in past and end is nil' do
      @member.temporary_location_until_date = nil
      @member.temp_location.should match @temploc
    end

    it 'returns value if start and end dates are both nil' do
      @member.temporary_location_from_date = nil
      @member.temporary_location_until_date = nil
      @member.temp_location.should match @temploc
    end

    describe 'when current' do

      it 'location is identified' do
        @member.temp_location.should match @temploc
      end

      it 'gives correct starting date' do
        @member.temp_location.should match (Date.today - 1.day).to_s(:short)
      end

      it 'gives correct ending date' do
        @member.temp_location.should match (Date.today + 1.day).to_s(:short)
      end
    end # when current
    
  end
  
  describe 'travel helpers' do
    before(:each) do
      @member = Factory(:member)
      @other = Factory(:member)
      @previous = Factory(:travel, :date=>Date.today-1.year, :member=>@member,
         :return_date=>Date.today-11.months)
      @current = Factory(:travel, :date=>Date.today-1.week, :member=>@member,
        :return_date=>Date.today+1.months)
      @future = Factory(:travel, :date=>Date.today+1.week, :member=>@member,
        :return_date=>Date.today+1.months)
      @far_future = Factory(:travel, :date=>Date.today+6.months, :member=>@member,
      :return_date=>Date.today+1.year)
      @current_no_return = Factory(:travel, :date=>Date.today-1.week, :member=>@member,
      :return_date=>nil)
      # Generate records for "other", which should NOT appear in @member's list of travel
      Factory(:travel, :date=>Date.today-1.year, :member=>@other,
         :return_date=>Date.today-11.months)
      Factory(:travel, :date=>Date.today-1.week, :member=>@other,
        :return_date=>Date.today+1.months)
      Factory(:travel, :date=>Date.today+1.week, :member=>@other,
        :return_date=>Date.today+1.months)
      Factory(:travel, :date=>Date.today+6.months, :member=>@other,
      :return_date=>Date.today+1.year)
      Factory(:travel, :date=>Date.today-1.week,:member=>@other,
      :return_date=>nil)
    end
    
    it 'identifies current travel' do
      @member.current_travel.should == [@current]
    end
    
    it 'identifies spouse as traveling if accompanied' do
      spouse = Factory.stub(:member, :spouse=>@member, :sex=>'F')
      @current.update_attribute(:with_spouse, true)
      spouse.current_travel.should == [@current]
    end
    
    it 'does not identify spouse as traveling if member traveling alone' do
      spouse = Factory.stub(:member, :spouse=>@member, :sex=>'F')
      spouse.current_travel.should == []
    end
    
    it 'identifies pending travel' do
      @member.pending_travel.should == [@future]
    end

    it 'identifies pending travel of spouse if member accompanied by spouse' do
      spouse = Factory.stub(:member, :spouse=>@member, :sex=>'F')
      @future.update_attribute(:with_spouse, true)
      spouse.pending_travel.should == [@future]
    end
    
    it 'does not identify pending travel of spouse if member not accompanied by spouse' do
      spouse = Factory.stub(:member, :spouse=>@member, :sex=>'F')
      spouse.pending_travel.should == []
    end
    
    
  end # 'travel helpers'
  
  describe 'identifies field terms' do
    before(:each) do
      @member = Factory(:member)
      @future_2 = Factory(:field_term, :member=>@member, :start_date=>Date.today+4.years, 
                :end_date=>Date.today+6.years)
      @future_1 = Factory(:field_term, :member=>@member, :start_date=>Date.today+2.days, 
                :end_date=>Date.today + 1.year) 
      @current_1 = Factory(:field_term, :member=>@member, :start_date=>Date.today-2.days, :end_date=>nil)
#      @current_3 = Factory(:field_term, :member=>@member, :start_date=>nil, :end_date=>Date.tomorrow + 1.year)
      @past_1 = Factory(:field_term, :member=>@member, :start_date=>Date.yesterday-1.year, :end_date=>Date.today-2.days)
#      @past_2 = Factory(:field_term, :member=>@member, :start_date=>nil, :end_date=>Date.today-2.days)
    end   

    it 'most recent' do
      @member.most_recent_term.should == @current_1
    end
    
    it 'pending' do
      @member.pending_term.should == @future_1
    end
    
    it 'current' do
      @member.current_term.should == @current_1
    end
  end #identifies field terms

  describe 'determines dates of next home assignment' do
    before(:each) do
      @current = Factory.build(:field_term, :start_date=>Date.today-1.year, :end_date=>Date.today+6.months)
      @future =  Factory.build(:field_term, :start_date=>Date.today+1.year, :end_date=>nil)
      @personnel = Factory.build(:personnel_data)
      @member = Factory.stub(:member)
      @member.stub(:most_recent_term).and_return(@current)
      @member.stub(:pending_term).and_return(@future)
      @member.stub(:personnel_data).and_return(@personnel)
    end

    it 'uses gap between terms if end of current & beginning of next are specified' do
      @member.most_recent_term.should == @current
      @member.pending_term.should == @future
      ha = @member.next_home_assignment
      ha[:start].should == @current.end_date + 1.day
      ha[:end].should == @future.start_date - 1.day
      ha[:end_estimated].should be_nil
      ha[:eot_status].should be_nil
    end

    it 'has unknown start of HA if end of current is unknown' do
      @current.end_date = nil
      ha = @member.next_home_assignment
      ha[:start].should be_nil
      ha[:end].should == @future.start_date - 1.day
      ha[:end_estimated].should be_nil
      ha[:eot_status].should be_nil
    end

    it 'estimates end of HA if current term specified and future not' do
      @future.start_date = nil
      ha = @member.next_home_assignment
      ha[:start].should == @current.end_date + 1.day
      ha[:end].should_not be_nil
      ha[:end_estimated].should_not be_nil
      ha[:eot_status].should be_nil
    end

    it 'gives unknown HA dates if end-current and begin-next are unspecified' do
      @future.start_date = nil
      @current.end_date = nil
      ha = @member.next_home_assignment
      ha[:start].should be_nil
      ha[:end].should be_nil
    end

    it 'notes end-of-service if end-term is near estimated retirement' do
      @personnel.est_end_of_service = @current.end_date + 60.days
      @member.next_home_assignment[:eot_status].should =~ /final|end|retir|termin/
    end
    
  end # determines dates of next home assignment
  
  describe 'mismatched statuses:' do
    before(:each) do
      @on_field = Factory(:status) # "field" is true by default
      @leave = Factory(:status, :on_field=>false, :leave=>true) # "field" is true by default
    end

    before(:each) do
      @travel = Factory.build(:travel, :member=>@member, :date=>Date.today-10, 
                        :return_date=>Date.today+10, :arrival=>false, :term_passage => true)
    end
    
    describe 'a member with on-field status' do
      before(:each) do
#        @status = Factory(:status) # "field" is true by default
        @member = Factory(:member_without_family, :status=>@on_field)
        @travel.member = @member
      end
            
      it 'is flagged if travel shows him as departed' do
        @travel.save
        Member.mismatched_status.should include({:travel=>@travel, :member=>@member})
      end 
      
      it 'is flagged if spouse travel shows him as departed' do
        @travel.with_spouse = true
        @travel.save
        spouse = Factory(:member_without_family, :sex=>'F', :spouse=>@member)
        @member.update_attribute(:spouse, spouse)
        mismatched = Member.mismatched_status
        mismatched.should include({:travel=>@travel, :member=>@member})
        mismatched.should include({:travel=>@travel, :member=>spouse})
      end 
      
      it 'is not flagged if spouse travel shows him as departed but not accompanied' do
        @travel.with_spouse = false
        @travel.save
        spouse = Factory(:member_without_family, :sex=>'F', :spouse=>@member)
        @member.update_attribute(:spouse, spouse)
        mismatched = Member.mismatched_status
        mismatched.should include({:travel=>@travel, :member=>@member})
        mismatched.should_not include({:travel=>@travel, :member=>spouse})
      end 
      
      it 'is not flagged if travel does not show him as departed' do
        @travel[:arrival] = true
        @travel.save
        Member.mismatched_status.should_not include({:travel=>@travel, :member=>@member})
      end 
      
      it 'is not flagged if recent travel is completed (return date is past)' do
        @travel.return_date = Date.today - 2.days
        @travel.save
        Member.mismatched_status.should_not include({:travel=>@travel, :member=>@member})
      end 
      
      it 'is not flagged if there is no travel record' do
        Member.mismatched_status.should be_empty
      end 
      
      it 'is not flagged if status is deceased!' do
        @deceased = Factory.stub(:status, :code=>'deceased', :on_field=>false)
        @member.update_attribute(:status, @deceased)
        @member.status.code.should == 'deceased'
        @travel.save
        Member.mismatched_status.should be_empty
      end 
      
      
    end # when member listed as on-field
       
    describe 'a member with off-field status' do
      before(:each) do
#        @status = Factory(:status, :on_field=>false, :leave=>true) # "field" is true by default
        @member = Factory(:member_without_family, :status=>@leave)
        @travel.member = @member
      end
            
      it 'is flagged if travel shows him as arrived' do
        @travel[:arrival] = true
        @travel.save
        Member.mismatched_status.should include({:travel=>@travel, :member=>@member})
      end 

      it 'is not flagged if status is deceased even if arrival shows arrived' do
        @deceased = Factory.stub(:status, :code=>'deceased', :on_field=>false)
        @member.update_attribute(:status, @deceased)
        @member.status.code.should == 'deceased'
        @travel[:arrival] = true
        @travel.save
        Member.mismatched_status.should be_empty
      end 

    end # when member listed as off-field
     
  end # finds mismatched statuses
  
  # For testing handling of travel records and on field status, make some travel records for @member.
  # Take an array like [ [-5,true], [-3, false], [4,true]] to generate travel records
  # where first of pair is date
  #       second of pair is true for arrival, false for departure
  def set_up_travel_records(travels, with_spouse=false)
    travels.each do |t|
      Factory.create(:travel, :member=>@member, :date=>t[0], :arrival=>t[1], :with_spouse=>with_spouse)
    end
  end
  
  describe 'in_country_per_travel:' do    

    before(:each) do
      @on_field = Factory.stub(:status) # "field" is true by default
      @member = Factory(:member_without_family, :status=>@on_field)
      @past = Date.today-20.days
      @recent = Date.today - 5.days
      @future = Date.today + 10.days
    end
            
    describe 'when past travel exists' do
      it 'returns true when last travel is arrival' do
        set_up_travel_records([ [@past, false], [@recent, true], [@future, false] ])
        @member.in_country_per_travel.should be_true
      end
      it 'returns true when last travel is arrival and member is leaving today' do
        set_up_travel_records([ [@past, false], [@recent, true], [@future, false] ])
        @member.in_country_per_travel.should be_true
      end
      it 'returns false when last travel is not arrival' do
        set_up_travel_records([ [@past, false], [@recent, false], [@future, false] ])
        @member.in_country_per_travel.should be_false
      end
    end # when past travel exists

    describe 'when referring to spouse' do
      before(:each) do
        @spouse = create_spouse(@member)
      end

      it 'returns true when spouse accompanied arriving member' do
        set_up_travel_records([ [@past, false], [@recent, true] ], true)
        @member.in_country_per_travel.should be_true
        @spouse.in_country_per_travel.should be_true
      end   

      it 'returns false when spouse did not accompany arriving member' do
        set_up_travel_records([ [@past, false], [@recent, true] ], false)
        @member.in_country_per_travel.should be_true
        @spouse.in_country_per_travel.should be_false
      end   

      # A tricky one
      it 'returns true when spouses arrived together but other spouse has departed' do
        set_up_travel_records([ [@past, true]], true) # Arrived together
        @member.in_country_per_travel.should be_true
        @spouse.in_country_per_travel.should be_true
        set_up_travel_records([ [@recent, false]], false) # @member departed alone
        @member.in_country_per_travel.should be_false
        @spouse.in_country_per_travel.should be_true
      end
      
      # Another tricky one
      it 'returns false when spouses arrived separately but leave together' do
        set_up_travel_records([ [@past, true]], false) # @member arrived
        @member.in_country_per_travel.should be_true
        @spouse.in_country_per_travel.should be_false
        Factory.create(:travel, :member=>@spouse, :date=>@past, :arrival=>true, :with_spouse=>false)
            # @spouse arrived separately
        @member.in_country_per_travel.should be_true
        @spouse.in_country_per_travel.should be_true
        set_up_travel_records([ [@recent, false]], true) # @member departed together
        @member.in_country_per_travel.should be_false
        @spouse.in_country_per_travel.should be_false
      end
      
    end

    describe 'when no past travel exists' do
      it 'returns true when member status is on_field' do
        set_up_travel_records([ [@future, false] ])
        @member.in_country_per_travel.should be_true
      end
      it 'returns true when status is on_field and member is leaving today' do
        set_up_travel_records([ [Date.today, false] ])
        @member.in_country_per_travel.should be_true
      end
      it 'returns false when member status is not on_field' do
        @leave = Factory(:status, :on_field=>false, :leave=>true) # "field" is true by default
        @member.update_attribute(:status, @leave)
        @member.in_country_per_travel.should be_false
      end
    end # when no past travel exists
  end # on_field_per_travel
  
  describe 'those_in_country:' do
    before(:each) do 
      @on_field = Factory(:status) # "field" is true by default
      @member = Factory(:member_without_family, :status=>@on_field)
    end
    
    it 'includes members w no travel but status=on_field' do
      Member.those_in_country.should == [@member]
    end
    it 'does not include members w no travel and status!=on_field' do
      @member.update_attribute(:status,nil)
      Member.those_in_country.include?(@member).should be_false
    end
  end # those_in_country

  describe 'export' do
    before(:each) do
      @member = Factory.build(:member_without_family, :birth_date => Date.new(1980,1,1))
      Member.stub(:all).and_return([@member])
    end      

    it 'makes csv object' do
#      @on_field = Factory.build(:status) # "field" is true by default
      csv = Member.export ['last_name', 'birth_date']
      csv.should match(@member.last_name)
      csv.should match(@member.birth_date.to_s(:long))
    end

    # Todo: Refactor next two into tests just for csv_helper or export
    it 'gracefully ignores unknown column names' do
      csv = Member.export ['last_name', 'xxxxxzzzz']
      csv.should match(@member.last_name)
    end

    it 'handles case with no column names' do
      # This test will pass regardless of what export returns; we just want to know that it doesn't crash
      csv = Member.export [] 
    end
      
  end # Export

  describe 'report_location' do
    
    it 'performed by update_reported_location' do
      @member = Factory(:member)
      @time = Time.new(2000,01,01,12,0)
      Time.stub(:now).and_return(@time)
      @member.update_reported_location('Hong Kong')
      @member.reload.reported_location_time.should == @time
      @member.reported_location.should == 'Hong Kong'
      @member.reported_location_expires.should == @time + DefaultReportedLocDuration*3600
    end
  end
      
      
      

end

