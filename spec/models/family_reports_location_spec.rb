require 'spec_helper'
include SimTestHelper

describe Family do
  describe "reports current location" do
    before(:each) do
      @head = Factory.stub(:member, :sex=>'M')
      @spouse = Factory.stub(:member, :spouse=>@head, :sex=>'F')
      @head.stub(:spouse).and_return(@spouse)
      @family = Factory.build(:family, :head=> @head)
    end    
    
    it "of single member", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home', :work=>'work'})
      @head.stub(:spouse).and_return(nil) # before(:each) creates couple, so must make single for test
      @family.current_location_hash.should == @head.current_location_hash
    end

    it "of couple when identical", :separate=> true do 
      @head.stub(:current_location_hash).
        and_return({:residence=>'Home', :work=>'work', :temp=>'temp', :travel=>'travel', :reported_location=>nil})
      @spouse.stub(:current_location_hash).and_return(@head.current_location_hash)
      @family.current_location_hash.should == @head.current_location_hash
    end

    it "of couple when residence is the same", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home', :work=>'his_work'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home', :work=>'her_work'})
      @family.current_location_hash[:residence].should == 'Home'
    end

    it "of couple when residence is different", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'His Home', :work=>'his_work'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Her Home', :work=>'her_work'})
      @family.current_location_hash[:residence].should =~ Regexp.new("#{@head.short_name}.*His Home.*#{@spouse.short_name}.*Her Home")
    end

    it "of couple when work is different", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home', :work=>'his_work'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home', :work=>'her_work'})
      @family.current_location_hash[:work].should =~ Regexp.new("#{@head.short_name}.*his_work.*#{@spouse.short_name}.*her_work")
    end

    it "of couple when work is the same", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home1', :work=>'their_work'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home2', :work=>'their_work'})
      @family.current_location_hash[:residence].should =~ /Home1.*Home2/
      @family.current_location_hash[:work].should == 'their_work'
    end

    it "of couple when travel is the same", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home1', :travel=>'their_travel'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home2', :travel=>'their_travel'})
      @family.current_location_hash[:travel].should == 'their_travel'
    end

    it "of couple when travel is different", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home', :travel=>'his_travel'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home', :travel=>'her_travel'})
      @family.current_location_hash[:travel].should =~ Regexp.new("#{@head.short_name}.*his_travel.*#{@spouse.short_name}.*her_travel")
    end

    it "of couple when only wife travels", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home', :travel=>'her_travel'})
      @family.current_location_hash[:travel].should =~ Regexp.new("^#{@spouse.short}.*her_travel$")
    end

    it "of couple when only husband travels", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home', :travel=>'his_travel'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home'})
      @family.current_location_hash[:travel].should =~ Regexp.new("^#{@head.short}.*his_travel$")
    end

    it "of couple when temp_location the same", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home1', :temp=>'their_temp'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home2', :temp=>'their_temp'})
      @family.current_location_hash[:temp].should == 'their_temp'
    end

    it "of couple when temp_location different", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home', :temp=>'his_temp'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home', :temp=>'her_temp'})
      @family.current_location_hash[:temp].should =~ Regexp.new("#{@head.short}.*his_temp.*#{@spouse.short}.*her_temp")
    end

    it "of couple when only wife has temp_location", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home', :temp=>'her_temp'})
      @family.current_location_hash[:temp].should =~ Regexp.new("^#{@spouse.short}.*her_temp$")
    end

    it "of couple when only husband has temp_location", :separate=> true do 
      @head.stub(:current_location_hash).and_return({:residence=>'Home', :temp=>'his_temp'})
      @spouse.stub(:current_location_hash).and_return({:residence=>'Home'})
      @family.current_location_hash[:temp].should =~ Regexp.new("^#{@head.short}.*his_temp$")
    end

  end
end

