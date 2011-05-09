require 'spec_helper'
include SimTestHelper

describe Family do
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
      end
      @head.spouse = nil  # before(:each) creates couple, so must make single for test
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

    it "of couple when residence is the same" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :work=>'his_work'} if self.male?
          return {:residence=>'Home', :work=>'her_work'}
        end
      end
      @family.current_location_hash[:residence].should == 'Home'
    end

    it "of couple when residence is different" do
      class Member
        def current_location_hash
          return {:residence=>'His Home', :work=>'his_work'} if self.male?
          return {:residence=>'Her Home', :work=>'her_work'}
        end
      end
      @family.current_location_hash[:residence].should =~ Regexp.new("#{@head.short_name}.*His Home.*#{@spouse.short_name}.*Her Home")
    end

    it "of couple when work is different" do
      class Member
        def current_location_hash
          return {:residence=>'Home', :work=>'his_work'} if self.male?
          return {:residence=>'Home', :work=>'her_work'}
        end
      end
      @family.current_location_hash[:work].should =~ Regexp.new("#{@head.short_name}.*his_work.*#{@spouse.short_name}.*her_work")
    end

    it "of couple when work is the same" do
      class Member
        def current_location_hash
          return {:residence=>'Home1', :work=>'their_work'} if self.male?
          return {:residence=>'Home2', :work=>'their_work'}
        end
      end
      @family.current_location_hash[:residence].should =~ /Home1.*Home2/
      @family.current_location_hash[:work].should == 'their_work'
    end

    it "of couple when travel is the same" do
      class Member
        def current_location_hash
          return {:residence=>'Home2', :travel=>'their_travel'} if self.male?
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
          return {:residence=>'Home', :temp=>'their_temp'}  if self.male?
          return {:residence=>'Home2', :temp=>'their_temp'}
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

