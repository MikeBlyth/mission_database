require 'spec_helper'
require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

describe MembersController do
  
  before(:each) do
    @family = Factory(:family)
    @member = @family.head
    Factory(:country_unspecified)
  end

  describe "authentication before controller access" do

    describe "for signed-in users" do
 
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should allow access to 'new'" do
        Member.should_receive(:new)
        get :new
      end
      
      it "should allow access to 'destroy'" do
        # Member.should_receive(:destroy) # Why can't this work ??
        put :destroy, :id => @member.id
        response.should_not redirect_to(signin_path)
      end
      
      it "should allow access to 'update'" do
        # Member.should_receive(:update)
        put :update, :id => @member.id, :record => @member.attributes, :member => @member.attributes
        response.should_not redirect_to(signin_path)
      end
      
    end # for signed-in users

    describe "for non-signed-in users" do

      it "should deny access to 'new'" do
        get :new
        response.should redirect_to(signin_path)
      end

    end # for non-signed-in users

  end # describe "authentication before controller access"

  describe 'filtering by status' do

    before(:each) do
      load "#{Rails.root}/db/seeds.rb" # A SLOW (~10 seconds) process
      Member.delete_all
      # This list should include all the status codes in use (or at least in seeds.rb)
      @status_codes = %w( alumni mkfield field college home_assignment leave mkadult retired deceased ) +
                     %w( pipeline mkalumni visitor_past visitor unspecified)
      # The groups reflect the status codes matched by the various filters. So, for example,
      #   the filter "active" (or :active) should trigger a selection string that includes the statuses with codes
      #   'field', 'home_assignment', and 'mkfield'
      # If the codes are changed, then this list will need to be changed, otherwise the tests will fail.
      # Note that the test does not care HOW conditions_for_collection creates the selection string (filter),
      #   only that it returns the right records.
      @status_groups = {:active => ['field', 'home_assignment', 'mkfield'],
                  :field => ['field', 'mkfield', 'visitor'],
                  :home_assignment => ['home_assignment'],
                  :home_assignment_or_leave => ['home_assignment', 'leave'],
                  :pipeline => ['pipeline'],
                  :visitor => ['visitor', 'visitor_past'],
                  :other => @status_codes - ['field', 'home_assignment', 'mkfield', 'visitor', 'visitor_past', 'leave', 'pipeline']
                  }
      # Create a member for each status
      @status_codes.each do |status_code|
        status=Status.find_by_code(status_code)
        puts "**** status code '#{status_code}' not found in Status table created by seeds.rb" unless status
        status.should_not be_nil # If it's nil, it means the codes in this test do not match those in seeds.rb
        member = Factory(:family, :status_id=>status.id)
      end  
    end
    
    it "should select members with the right status" do
      # This checks that the 'conditions_for_collection' method returns the right conditions to match the 
      #   status groups defined above, and that the conditions work to return the right records.
      Member.count.should == @status_codes.count
      @status_groups.each do | category, statuses |
        session[:filter] = category.to_s
#puts "\n**** Conditions for #{category} =#{statuses}:  #{controller.conditions_for_collection}"      
        Member.where(controller.conditions_for_collection).count.should == statuses.count
        Member.where(controller.conditions_for_collection).each do |m|
#         puts "****> #{m.status.code} #{m.status.id}, matching #{statuses}?"
          statuses.include?(m.status.code).should be_true
        end
      end
      # An invalid group should return all the members.
      session[:filter] = 'ALL!'
      Member.where(controller.conditions_for_collection).count.should == Member.count
      
    end    #  it "should select members with active status"

  end # filtering by status

end
