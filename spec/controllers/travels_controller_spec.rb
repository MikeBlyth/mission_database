require 'spec_helper'
#require "webrat"

#Webrat.configure do |config|
#  config.mode = :rails
#end

describe TravelsController do
  
  describe "role based authorization" do

    before(:each) do
        @user = Factory(:user, :travel=>true)
        test_sign_in(@user)
        @object = Factory.build(:travel)
    end

    describe "for authorized users" do
    
      it "should have access to new object form" do
#        Travel.should_receive(:new)
        get :new
        response.should render_template('create')
      end
      
      it "can create new object" do
        lambda do
          post :create, :record => {:date=>Date.today, :member => @object.member_id}
        end.should change(Travel, :count).by(1)      
      end

    end # for authorized users

    describe "for unauthorized users" do
    
      before(:each) {@user.update_attribute(:travel, false)}
      
      it "should have not access to new object form" do
#        Travel.should_not_receive(:new)
        get :new
      end
      
      it "cannot create new object" do
        lambda do
          post :create, :record => {:date=>Date.today, :member_id => @object.member_id}
        end.should change(Travel, :count).by(0)      
      end

    end # for authorized users

  end # role based authorization
  

  describe 'filtering' do

    before(:each) do
      @arrival = Factory(:travel, :arrival=>true)
      @departure = Factory(:travel, :arrival=>false)
      @old = Factory(:travel, :date=>Date.today-1.year) 
    end
    
    it "should filter by :travel_filter setting in session" do
      # This checks that the 'conditions_for_collection' method returns the right conditions to match the 
      #   status groups defined above, and that the conditions work to return the right records.
      ['arrivals', 'departures', 'current', 'all_dates'].each do | filtr |
        session[:travel_filter] = filtr # Is filter a reserved word?
        filtered = Travel.where(controller.conditions_for_collection).order("arrival ASC")
#puts "controller.conditions_for_collection= #{controller.conditions_for_collection}"
#puts "SQL = #{Travel.where(controller.conditions_for_collection).to_sql}"
#puts "Filtered = #{filtered.all}"
        case filtr
          when 'arrivals'
            filtered.should == [@arrival]
          when 'departures'
            filtered.should == [@departure]
          when 'current'
            filtered.should == [@departure, @arrival]
          when 'all_dates'
            filtered.count.should == Travel.count
        end    
      end # each filter
    end # it ...

  end # filtering by status

  describe "automatic return trip" do
    
    before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
        @member = Factory(:family).head
        @attr = {:member=>"#{@member.id}", :date=>Date.today, :arrival=>false, 
              :time => Time.new(1,1,1,5,15,0,"+01:00"),
              :return_time => Time.new(1,1,1,6,45,0,"+01:00"),
              :confirmed=>Date.today}
    end
    
    it "should not be created when new travel has no return date" do
        lambda do
          post :create, :record=>@attr
        end.should change(Travel, :count).by(1)
    end
 
    it "should be created when new travel has return date" do
        @attr[:return_date] = Date.today + 1.month
        lambda do
          post :create, :record=>@attr
        end.should change(Travel, :count).by(2)
        return_trip = Travel.last
        return_trip.date.should == @attr[:return_date]
        return_trip.return_date.should == nil
        return_trip.origin.should == @attr[:destination]
        return_trip.destination.should == @attr[:origin]
        return_trip.time == @attr[:return_time]
        return_trip.arrival.should be_true
        return_trip.confirmed.should be_nil
    end
 
  end #automatic return trip
  
  # Allow travel records that are not attached to a member -- such as for guests, teams etc.
  describe "Guest passengers" do

    before(:each) do
        @user = Factory(:user, :travel=>true)
        test_sign_in(@user)
        @attr = {:member=>'999999', :date=>Date.today, :other_travelers=>'Guest traveler'}
    end

    it "should add 'Guest' travel if member_id is 'Unspecified'" do
        lambda do
          post :create, :record=>@attr
        end.should change(Travel, :count).by(1)
        Travel.last.traveler.full_name.should == 'Guest traveler'
    end        
    
    it "should add 'Guest' travel if member_id is empty" do
        @attr[:member] = ''
        lambda do
          post :create, :record=>@attr
        end.should change(Travel, :count).by(1)
        Travel.last.traveler.full_name.should == 'Guest traveler'
    end        
    
    it "should not add 'Guest' travel if other_travelers is empty" do
        @attr[:other_travelers] = ''
        lambda do
          post :create, :record=>@attr
        end.should change(Travel, :count).by(0)
    end        
    
  end # Guest passengers

  describe "Multiple members to add" do

    before(:each) do
      @user = Factory(:user, :travel=>true)
      test_sign_in(@user)
      @member_1 = Factory(:member)
      @member_2 = Factory(:member, :last_name=>"Francis")
      @member_3 = Factory(:member, :last_name=>"Ghandi")
      @ids = [@member_1.id.to_s, @member_2.id.to_s, @member_3.id.to_s]    
      @attr = {:member=>@ids, :date=>Date.today}
    end

    it "generates record for single member in array" do
      @attr[:member] = [@member_1.id.to_s]  # Just use the first one
      lambda do
        post :create, :record=>@attr
      end.should change(Travel, :count).by(1)
    end        
      
    it "generates record for multiple members in array" do
      lambda do
        post :create, :record=>@attr
      end.should change(Travel, :count).by(@ids.count)
      @ids.each do |member_id|
        Travel.find_by_member_id(member_id).should_not be_nil
      end  
    end        

  end # Multiple members
  
  
end
