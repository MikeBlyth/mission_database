require 'spec_helper'
require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

describe TravelsController do
  

#  describe "authentication before controller access" do

#    describe "for signed-in users" do
# 
#      before(:each) do
#        @user = Factory(:user)
#        test_sign_in(@user)
#      end
#      
#      it "should allow access to 'new'" do
#        Member.should_receive(:new)
#        get :new
#      end
#      
#      it "should allow access to 'destroy'" do
#        # Member.should_receive(:destroy) # Why can't this work ??
#        put :destroy, :id => @member.id
#        response.should_not redirect_to(signin_path)
#      end
#      
#      it "should allow access to 'update'" do
#        # Member.should_receive(:update)
#        put :update, :id => @member.id, :record => @member.attributes, :member => @member.attributes
#        response.should_not redirect_to(signin_path)
#      end
#      
#    end # for signed-in users

#    describe "for non-signed-in users" do

#      it "should deny access to 'new'" do
#        get :new
#        response.should redirect_to(signin_path)
#      end

#    end # for non-signed-in users

#  end # describe "authentication before controller access"

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

end
