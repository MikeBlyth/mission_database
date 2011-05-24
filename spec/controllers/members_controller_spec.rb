require 'spec_helper'

def seed_statuses
  Status.create(:description => 'On the field', :code => 'on_field', :active => true, :on_field => true,
      :pipeline=>false, :leave=>false, :home_assignment=>false)
  Status.create(:description => 'Pipeline', :code => 'pipeline', :active => false, :on_field => false,
      :pipeline=>true, :leave=>false, :home_assignment=>false)
  Status.create(:description => 'Home_assignment', :code => 'home_assignment', :active => true, :on_field => false,
      :pipeline=>false, :leave=>false, :home_assignment=>true)
  Status.create(:description => 'Leave', :code => 'leave', :active => false, :on_field => false,
      :pipeline=>false, :leave=>true, :home_assignment=>false)
  Status.create(:description => 'Inactive', :code => 'inactive', :active => false, :on_field => false,
      :pipeline=>false, :leave=>false, :home_assignment=>false)
end

describe MembersController do
  
  before(:each) do
    @family = Factory(:family)
    @member = Factory(:member, :family=>@family)
    @family.update_attribute(:head, @member)
    Factory(:country_unspecified)
  end

  describe "authentication before controller access" do

    describe "for signed-in admin users" do
 
      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
      end
      
      it "should allow access to 'new'" do
        Member.should_receive(:new).at_least(1).times # not sure why, but it is receiving msg twice!
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

  # These should probably be put into the member MODEL spec
  describe 'filtering by status' do

    before(:each) do
      Member.delete_all  
      seed_statuses
      status_codes = Status.all.map {|status| status.code}
      @status_groups = {:active => ['on_field', 'home_assignment'],
                  :on_field => ['on_field'],
                  :home_assignment => ['home_assignment'],
                  :home_assignment_or_leave => ['home_assignment', 'leave'],
                  :pipeline => ['pipeline'],
                  }
      other = status_codes - @status_groups.values.flatten.uniq
      @status_groups[:other] = other
      # Create a member for each status
      Status.all.each do |status|
        member = Factory(:member_without_family, :status=>status)
      end  
    end
    
    it "should select members with the right status" do
      @status_groups.each do | category, statuses |
        session[:filter] = category.to_s
        selected = Member.where(controller.conditions_for_collection).all
        if selected.count != statuses.count
          puts "Error: looking for category '#{category}' statuses #{statuses}, found"
          selected.each {|m| puts "--#{m.status}"}
        end
        selected.count.should == statuses.count
        selected.each do |m|
          statuses.include?(m.status.code).should be_true
        end
      end
      # An invalid group should return all the members.
      session[:filter] = 'ALL!'
      Member.where(controller.conditions_for_collection).count.should == Member.count
      # A filter=nil should return all the members.
      session[:filter] = nil
puts "conditions=#{controller.conditions_for_collection}"      
      Member.where(controller.conditions_for_collection).count.should == Member.count
      
    end    #  it "should select members with active status"

  end # filtering by status

  describe 'Handling spouses' do
  
    before(:each) do
      @spouse = Factory.build(:member, :family_id=>@family.id, :sex=>@member.other_sex, :spouse=>@member)
      @user = Factory(:user, :admin=>true)
      test_sign_in(@user)
    end  
  
    it 'sets previous_spouse in an update' do
      @spouse.save
      @member.reload.spouse.should == @spouse
      @spouse.spouse.should == @member
      put :update, :id => @member.id, :record => {'short_name' => 'Nicky', 'spouse'=>""}
      @member.reload.spouse.should == nil
      @spouse.reload.spouse.should == nil
    end  

  end
  
end
