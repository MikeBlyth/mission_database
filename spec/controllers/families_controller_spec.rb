require 'spec_helper'
#require "webrat"

#Webrat.configure do |config|
#  config.mode = :rails
#end

describe FamiliesController do
  
  before(:each) do
    @family = Factory(:family)
    @member = @family.head
  end

  describe "authentication before controller access" do

    describe "for signed-in admin users" do
 
      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
      end
      
      it "should allow access to 'new'" do
        Family.should_receive(:new)
        get :new
      end
      
      it "should allow access to 'destroy'" do
        # Family.should_receive(:destroy) # Why can't this work ??
        lambda do
          put :destroy, :id => @family.id
          response.should_not redirect_to(signin_path)
        end.should change(Family, :count).by(-1)  
      end
      
      it "should allow access to 'update'" do
        # Family.should_receive(:update)
        put :update, :id => @family.id, :record => @family.attributes, :family => @family.attributes
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
      Family.delete_all
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
      # Create a family for each status
      @status_codes.each do |status_code|
        status=Status.find_by_code(status_code)
        puts "**** status code '#{status_code}' not found in Status table created by seeds.rb" unless status
        status.should_not be_nil # If it's nil, it means the codes in this test do not match those in seeds.rb
        family = Factory(:family, :status_id=>status.id)
      end  
    end
    
    it "should select families with the right status" do
      # This checks that the 'conditions_for_collection' method returns the right conditions to match the 
      #   status groups defined above, and that the conditions work to return the right records.
      Family.count.should == @status_codes.count
      @status_groups.each do | category, statuses |
        session[:filter] = category.to_s
        Family.where(controller.conditions_for_collection).count.should == statuses.count
        Family.where(controller.conditions_for_collection).each do |m|
          statuses.include?(m.status.code).should be_true
        end
      end
      # An invalid group should return all the familys.
      session[:filter] = 'ALL!'
      Family.where(controller.conditions_for_collection).count.should == Family.count
    end    #  it "should select families with active status"
  end # filtering by status

  describe 'residence and status of family members:' do

    before(:each) do
      @user = Factory(:user, :admin=>true)
      test_sign_in(@user)
      @original_location = Factory(:location, :description=>"Original Location")
      @new_location = Factory(:location, :description=>"New Location")
      @original_status = Factory(:status, :description=>"Original status")
      @new_status = Factory(:status, :description=>"New status")
      @family = Factory(:family,:residence_location=>@original_location, :status=>@original_status)
      @member = @family.head
      @spouse = Factory(:member, :family=>@family, :last_name=>@family.last_name, :spouse=>@member, :child=>false,
              :sex=>@member.other_sex)
      @child = Factory(:member, :family=>@family, :last_name=>@family.last_name, :child=>true, :spouse=>nil)
    end
    
    it "single member (head) location should change when family location is changed" do
      new_attributes = {'residence_location' => @new_location.id.to_s} 
      @member.update_attribute(:spouse, nil)
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.residence_location_id.should == @new_location.id
      @member.reload.residence_location.should == @new_location
    end
    
    it "single member (head) status should change when family status is changed" do
      new_attributes = {'status' => @new_status.id.to_s} 
      @member.update_attribute(:spouse, nil)
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.status.should == @new_status
      @member.reload.status.should == @new_status
    end
    
    it "spouse's & child's location should change when family location is changed" do
      new_attributes = {'residence_location' => @new_location.id.to_s} 
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.residence_location_id.should == @new_location.id
      @member.reload.residence_location.should == @new_location
      @spouse.reload.residence_location.should == @new_location
      @child.reload.residence_location.should == @new_location
    end
    
    it "location should not change when family location is not changed" do
      same_attributes = {'residence_location' => @original_location.id.to_s} 
      @member.update_attribute(:residence_location, @new_location) # customize one of the members' location
      put :update, :id => @family.id, :record => same_attributes # update family, but don't change location
      @family.reload.residence_location_id.should == @original_location.id
      @member.reload.residence_location.should == @new_location
      @spouse.reload.residence_location.should == @original_location
      @child.reload.residence_location.should == @original_location
    end

    it "location of non-dependents should not change when family location is changed" do
    # That is, only head, kids & spouse should change, no other. 
      new_attributes = {'residence_location' => @new_location.id.to_s} 
      @other_member = Factory(:member, :family=>@family, :last_name=>@family.last_name, :child=>false, :spouse=>nil)
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.residence_location_id.should == @new_location.id
      @other_member.reload.residence_location.should == @original_location
      @member.reload.residence_location.should == @new_location
    end

    it "status of non-dependents should not change when family location is changed" do
    # That is, only head, kids & spouse should change, no other. 
      new_attributes = {'status' => @new_status.id.to_s} 
      @other_member = Factory(:member, :family=>@family, :last_name=>@family.last_name, :child=>false, :spouse=>nil)
      put :update, :id => @family.id, :record => new_attributes
      @other_member.reload.status.should ==@original_status
      @member.reload.status.should == @new_status
    end

    it "status should change when family status is changed" do
      new_attributes = {'status' => @new_status.id.to_s} 
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.status_id.should == @new_status.id
      @member.reload.status.should == @new_status
      @spouse.reload.status.should == @new_status
    end
    
    it "status should not change when family status is not changed" do
      same_attributes = {'status' => @original_status.id.to_s} 
      @member.update_attribute(:status, @new_status) # customize one of the members' status
      put :update, :id => @family.id, :record => same_attributes
      @family.reload.status_id.should == @original_status.id
      @member.reload.status.should == @new_status
      @spouse.reload.status.should == @original_status
    end

  end    
  
  describe "member list" do
    include FamiliesHelper
    
    it "exists" do
      members_column(@family).should_not be_nil
    end
    
    it "includes names in right order" do
      @wife = Member.create(:first_name=>'Wife', :sex=>'F', :family=>@family)
      @family.head = @wife
      @member.destroy
      @baby = Member.create(:first_name=>'Baby', :sex=>'F', :family=>@family,
                            :child=>true, :birth_date=>Date.today)
      @child = Member.create(:first_name=>'Kid', :sex=>'F', :family=>@family,
                            :child=>true, :birth_date=>Date.today-10.years)
      @husband =  Member.create(:first_name=>'Husband', :sex=>'M', :family=>@family)
      @husband.marry(@wife)                     
      names = members_column(@family).split(Settings.family.member_names_delimiter)
      names.should == ["Husband", "Wife", "Kid", "Baby"] 
    end 

    it "does not include non-dependent kids" do
      big_kid = Member.create(:family=>@family, :first_name=>'Big', :child=>false)
      @family.members.include?(big_kid).should be_true
      members_column(@family).should_not =~ /Big/ if Settings.family.member_names_dependent_only
    end

  end    
  
end
