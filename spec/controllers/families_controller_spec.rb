require 'spec_helper'
require 'sim_test_helper'

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


describe FamiliesController do
include SimTestHelper
  
  before(:each) do
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
        @family = Factory(:family)
        lambda do
          put :destroy, :id => @family.id
          response.should_not redirect_to(signin_path)
        end.should change(Family, :count).by(-1)  
      end
      
      it "should allow access to 'update'" do
        @family = Factory(:family)
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

  describe 'new_family also creates family head' do
    before(:each) do
        @user = Factory.build(:user, :admin=>true)
        test_sign_in(@user)
      @params={:record=>{:last_name=>"Last", :first_name=>"First", :name=>"AllName"}}
    end  

    it 'creates a "family head" member' do
      lambda{post :create, @params}.should change(Member, :count).by(1)  
      family = Family.last
      family.should_not be_nil
      family.head.should_not be_nil
    end

    it 'family head member belongs to family' do
      lambda{post :create, @params}.should change(Member, :count).by(1)  
      family = Family.last
      family.head.family.should == family
    end

    it 'family head inherits family info' do
      status = Factory(:status)
      location = Factory(:location)
      lambda do
        @params[:record].merge!({:status=>status.id.to_s, :residence_location=>location.id.to_s})
        post :create, @params
       end.should change(Member, :count).by(1)  
      family = Family.last
      head = family.head.reload
      head.status.should == status
      head.residence_location.should == location
      head.name.should == family.name
      head.last_name.should == family.last_name
      head.first_name.should == family.first_name
      head.middle_name.should == family.middle_name
    end

  end # 'new_family also creates family head'

  # These should probably be put into the family MODEL spec
  # TODO: Remove duplication between this and Member controller spec, including seed_statuses
  describe 'filtering by status' do

    before(:each) do
      Family.delete_all  
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
      # Create a family for each status
      Status.all.each do |status|
        family = Factory(:family, :status=>status)
      end  
    end
    
    it "should select families with the right status" do
      @status_groups.each do | category, statuses |
        session[:filter] = category.to_s
        selected = Family.where(controller.conditions_for_collection).all
        if selected.count != statuses.count
          puts "Error: looking for category '#{category}' statuses #{statuses}, found"
          selected.each {|m| puts "--#{m.status}"}
        end
        selected.count.should == statuses.count
        selected.each do |m|
          statuses.include?(m.status.code).should be_true
        end
      end
      # An invalid group should return all the Families.
      session[:filter] = 'ALL!'
      Family.where(controller.conditions_for_collection).count.should == Family.count
      
    end    #  it "should select famlies with the right status"

  end # filtering by status

  describe 'residence and status of family members:' do

    before(:each) do
      @user = Factory(:user, :admin=>true)
      test_sign_in(@user)
      @original_location = Factory(:location, :description=>"Original Location")
      @new_location = Factory(:location, :description=>"New Location")
      @original_status = Factory(:status, :description=>"Original status")
      @new_status = Factory(:status, :description=>"New status")
      @career_status = Factory(:employment_status)
      @member = Factory(:member)
      @family = Factory(:family,:residence_location=>@original_location, 
              :head=>@member, :status=>@original_status)
      @member.update_attribute(:family, @family)
      @member.personnel_data.update_attributes(:employment_status=>@career_status)
      @spouse = Factory(:member, :family=>@family, :last_name=>@family.last_name, :spouse=>@member, :child=>false,
              :sex=>@member.other_sex)
      @spouse.personnel_data.update_attributes(:employment_status=>@career_status)
      @dep_mk = Factory(:employment_status, :code=>'mk_dependent')
      @child = Factory(:member, :family=>@family, :last_name=>@family.last_name, :child=>true, :spouse=>nil)
      @child.personnel_data.update_attributes(:employment_status => @dep_mk)
    end
    
    it "single member (head) location should change when family location is changed" do
      new_attributes = {'residence_location_id' => @new_location.id} 
      @member.update_attribute(:spouse, nil)
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.residence_location_id.should == @new_location.id
      @member.reload.residence_location.should == @new_location
    end
    
    it "single member (head) status should change when family status is changed" do
      new_attributes = {'status_id' => @new_status.id} 
      @member.update_attribute(:spouse, nil)
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.status.should == @new_status
      @member.reload.status.should == @new_status
    end
    
    it "spouse's & child's location should change when family location is changed" do
      new_attributes = {'residence_location_id' => @new_location.id} 
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.residence_location_id.should == @new_location.id
      @member.reload.residence_location.should == @new_location
      @spouse.reload.residence_location.should == @new_location
      @child.reload.residence_location.should == @new_location
    end
    
    it "location should not change when family location is not changed" do
      same_attributes = {'residence_location_id' => @original_location.id} 
      @member.update_attribute(:residence_location, @new_location) # customize one of the members' location
      put :update, :id => @family.id, :record => same_attributes # update family, but don't change location
      @family.reload.residence_location_id.should == @original_location.id
      @member.reload.residence_location.should == @new_location
      @spouse.reload.residence_location.should == @original_location
      @child.reload.residence_location.should == @original_location
    end

    it "location of non-dependents should not change when family location is changed" do
    # That is, only head, kids & spouse should change, no other. 
      new_attributes = {'residence_location_id' => @new_location.id} 
      @other_member = Factory(:member, :family=>@family, :last_name=>@family.last_name, :child=>false, :spouse=>nil)
      @other_member.personnel_data.update_attributes(:employment_status=>@career_status)
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.residence_location_id.should == @new_location.id
      @other_member.reload.residence_location.should == @original_location
      @member.reload.residence_location.should == @new_location
    end

    it "status of non-dependents should not change when family location is changed" do
    # That is, only head, kids & spouse should change, no other. 
      new_attributes = {'status_id' => @new_status.id} 
      @other_member = Factory(:member, :family=>@family, :last_name=>@family.last_name, :child=>false, :spouse=>nil)
      @other_member.personnel_data.update_attributes(:employment_status=>@career_status)
      put :update, :id => @family.id, :record => new_attributes
      @other_member.reload.status.should ==@original_status
      @member.reload.status.should == @new_status
    end

    it "status should change when family status is changed" do
      new_attributes = {'status_id' => @new_status.id} 
      put :update, :id => @family.id, :record => new_attributes
      @family.reload.status_id.should == @new_status.id
      @member.reload.status.should == @new_status
      @spouse.reload.status.should == @new_status
    end
    
    it "status should not change when family status is not changed" do
      same_attributes = {'status_id' => @original_status.id} 
      @member.update_attribute(:status, @new_status) # customize one of the members' status
      put :update, :id => @family.id, :record => same_attributes
      @family.reload.status_id.should == @original_status.id
      @member.reload.status.should == @new_status
      @spouse.reload.status.should == @original_status
    end

  end    
  
  describe "member list" do
    include FamiliesHelper
    before(:each) do
      @member = Factory(:member)
      @family = Factory(:family, :head=>@member)
      @member.update_attribute(:family, @family)
      @career_status = Factory(:employment_status)
      @dep_mk = Factory(:employment_status, :code=>'mk_dependent')
    end      
    
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
      @husband.personnel_data.update_attributes(:employment_status=>@career_status)
      @wife.personnel_data.update_attributes(:employment_status=>@career_status)
      @child.personnel_data.update_attributes(:employment_status=>@dep_mk)
      @baby.personnel_data.update_attributes(:employment_status=>@dep_mk)
      names = members_column(@family).split(Settings.family.member_names_delimiter)
      names.should == ["Husband", "Wife", "Kid", "Baby"] 
    end 

    it "does not include non-dependent kids" do
      big_kid = Member.create(:family=>@family, :first_name=>'Big', :child=>false)
      big_kid.personnel_data.update_attributes(:employment_status=>@career_status)
      @family.head.personnel_data.update_attributes(:employment_status=>@career_status)
      @family.members.include?(big_kid).should be_true
      members_column(@family).should_not =~ /Big/ if Settings.family.member_names_dependent_only
    end

  end    

  describe 'updating a family from combined form' do
    before (:each) do
      test_sign_in(Factory.stub(:user, :admin=>true))
      @head=factory_member_basic
      @family = @head.family
      @family.head = @head
      @params = {:id=>@family.id, :record=>{}}
    end
      
    it 'updates the head' do
#        lambda {put :update, :id=>@family.id, :record=>{}}.should change(Member, :count).by(0)
      updates = {:head=>{:first_name=>'Gordon'}}
      put :update, @params.merge(updates)
      @head.reload.first_name.should == 'Gordon'
    end  
    
    it 'updates the wife' do
      wife = create_spouse(@head)
      updates = {:wife=>{:first_name=>'Grace'}}
      put :update, @params.merge(updates)
      wife.reload.first_name.should == 'Grace'
    end  
    
    it 'updates a child' do
      child = @family.add_child(:first_name=>'Junior')
      updates = {:member=>{child.id.to_s=>{:first_name=>'Junior'} } }
      put :update, @params.merge(updates)
      child.reload.first_name.should == 'Junior'
    end  
    
    it 'updates family' do
      updates = {:record=>{:first_name=>'Grace'}}
      put :update, @params.merge(updates)
      @family.reload.first_name.should == 'Grace'
    end      

    it 'adds child' do
      updates = {:member=>{10000000001.to_s=>{:first_name=>'Zinger'} } }
      lambda {put :update, @params.merge(updates)}.should change(Member, :count).by(1)
      @family.reload.children.first.first_name.should == 'Zinger'
    end            
    
    it 'adds wife' do
      updates = {:wife=>{:first_name=>'Grace', :sex=>'F'} }
      lambda {put :update, @params.merge(updates)}.should change(Member, :count).by(1)
      Member.last.first_name.should == 'Grace'
      @head.reload.spouse.should_not be_nil
      @family.reload.wife.should_not == nil
      @family.wife.first_name.should == 'Grace'
    end            
    
  end # updating a family
    
end
