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
          post :create, :record => {:date=>Date.today, :member_id => @object.member_id}
        end.should change(Travel, :count).by(1)      
      end

    end # for authorized users

    describe "for unauthorized users" do
    
      before(:each) {@user.update_attribute(:travel, false)}
      
      it "should have not access to new object form" do
#        Travel.should_not_receive(:new)
        get :new
      end
      
      it "can create new object" do
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
        @attr = {:member=>"#{@member.id}", :date=>Date.today, :arrival=>false, :confirmed=>Date.today}
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
        return_trip.arrival.should be_true
        return_trip.confirmed.should be_nil
    end
 
  end #automatic return trip
  
  # Allow travel records that are not attached to a member -- such as for guests, teams etc.
  describe "Guest passengers" do

    before(:each) do
        @user = Factory(:user, :travel=>true)
        test_sign_in(@user)
        @object = Factory.build(:travel)
    end

    
    
  end # Guest passengers
  
end
