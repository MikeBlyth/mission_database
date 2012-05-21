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

  describe 'make new, empty family' do
      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
      end
    
    it 'should make all required elements for new-family form' do
      get :new
      assigns[:head].should_not be_nil
      assigns[:wife].should_not be_nil
      assigns[:head].personnel_data.should_not be_nil
      assigns[:wife].personnel_data.should_not be_nil
      assigns[:children].should_not be_nil
#      puts assigns[:children][0].attributes
      
    end

  end

  describe 'create new family from form' do
      before(:each) do
          @user = Factory.build(:user, :admin=>true)
          test_sign_in(@user)
          @params={:record=>{:last_name=>"Last", :first_name=>"First", :name=>"AllName"},
                   :head=>{:last_name=>"Last", :first_name=>"First", :name=>"AllName"}
                   }
      end  

    describe 'when successful' do

      it 'Creates the new family record with minimal information' do
        post :create, @params
        family = Family.first
        family.last_name.should == @params[:record][:last_name]
        family.first_name.should == @params[:record][:first_name]
        head = family.head
        head.should_not be_nil
        head.last_name.should == 'Last'
        head.first_name.should == 'First'
        head.family.should == family
      end

      it 'adds wife when her data is given' do
        @params[:wife] = {:last_name=>"Last", :first_name=>"Mary", :name=>"MaryName"}
        post :create, @params
        family = Family.first
        family.wife.should_not be_nil
        family.wife.first_name.should == 'Mary'
      end

      it 'adds children when data is given' do
        @params[:member] = {10000000001.to_s=>{:first_name=>'Zinger'},
                            10000000002.to_s=>{:first_name=>'Zapper'},
                            } 
        post :create, @params
        family = Family.first
        family.children.count.should == 2
        family.children_names.should include('Zinger')
        family.children_names.should include('Zapper')
      end

      it 'should have no error messages' do
        post :create, @params
        assigns[:error_records].should == []
      end

      it 'redirects to families listing' do
        post :create, @params
  #puts "**** assigns[:error_records]=#{assigns[:error_records]}"
        response.should redirect_to(:action=>'index')
      end

      it 'adds phone numbers and email for head' do
        @params[:head_contact] = {:phone_1 => '+2348088888888', :phone_2 => '0802 222 2222',
                                  :email_1 => 'x@y.com', :email_2 => 'cat@dog.com'}
        post :create, @params
        head = family = Family.first.head
        head.primary_contact.should_not be_nil
        head.primary_contact.phone_1.should == '+2348088888888'
        head.primary_contact.phone_2.should == '+2348022222222'
        head.primary_contact.email_1.should == 'x@y.com'
        head.primary_contact.email_2.should == 'cat@dog.com'
      end
                
      it 'adds phone numbers and email for head' do
        @params[:wife] = {:first_name=>'Sally', :last_name=>'Jones'}
        @params[:wife_contact] = {:phone_1 => '+2348088888888', :phone_2 => '0802 222 2222',
                                  :email_1 => 'x@y.com', :email_2 => 'cat@dog.com'}
        post :create, @params
        wife = family = Family.first.wife
        wife.primary_contact.should_not be_nil
        wife.primary_contact.phone_1.should == '+2348088888888'
        wife.primary_contact.phone_2.should == '+2348022222222'
        wife.primary_contact.email_1.should == 'x@y.com'
        wife.primary_contact.email_2.should == 'cat@dog.com'
      end
                
    end # when successful
    
    describe 'handles errors' do
      
      it 'in child' do
        @params[:member] = {10000000001.to_s=>{:first_name=>'Zinger', :birth_date=>(Date.today + 2).strftime("%F")}
                            } 
        lambda{post :create, @params}.should_not change(Member, :count)
#puts "**** assigns[:error_records][0].errors=#{assigns[:error_records][0].errors}"
        assigns[:error_records].should_not == []
      end
    end # handles errors

    describe 'when unsuccessful' do
      before(:each) do
        @params={:record=>{:last_name=>"Last", :first_name=>"First", :name=>"AllName"},
                 :head=>{:last_name=>nil, :first_name=>"First", :name=>"AllName"},
                 :wife=>{:last_name=>"Last", :first_name=>"Mary", :name=>"MaryName"},
                 :member=>{10000000001.to_s=>{:first_name=>'Zinger'} } 
                 }
      end  

      it 'does not save family' do
        lambda{post :create, @params}.should_not change(Family, :count)
      end
        
      it 'does not save members' do
        lambda{post :create, @params}.should_not change(Member, :count)
      end

      it 'returns to "create" form' do
        post :create, @params
        response.should render_template("create")
      end
      
    end # when unsuccessful

  end # create new family from form


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
      new_attributes = {'status_id' => @new_status.id.to_s} 
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
    
#    it "location should not change when family location is not changed" do
#      same_attributes = {'residence_location_id' => @original_location.id} 
#      @member.update_attribute(:residence_location, @new_location) # customize one of the members' location
#      put :update, :id => @family.id, :record => same_attributes # update family, but don't change location
#      @family.reload.residence_location_id.should == @original_location.id
#      @member.reload.residence_location.should == @new_location
#      @spouse.reload.residence_location.should == @original_location
#      @child.reload.residence_location.should == @original_location
#    end

#    it "location of non-dependents should not change when family location is changed" do
#    # That is, only head, kids & spouse should change, no other. 
#      new_attributes = {'residence_location_id' => @new_location.id} 
#      @other_member = Factory(:member, :family=>@family, :last_name=>@family.last_name, :child=>false, :spouse=>nil)
#      @other_member.personnel_data.update_attributes(:employment_status=>@career_status)
#      put :update, :id => @family.id, :record => new_attributes
#      @family.reload.residence_location_id.should == @new_location.id
#      @other_member.reload.residence_location.should == @original_location
#      @member.reload.residence_location.should == @new_location
#    end

    it "status of non-dependents should not change when family status is changed" do
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
    
    describe 'updates field term dates' do
      before(:each) do
        @date_1_orig = Date.today+50
        @date_2_orig = Date.today+250
        @date_1 = Date.today+2
        @date_2 = Date.today+100
        @current_term = @head.field_terms.create(:end_date=>@date_1_orig, :end_estimated=>true)
        @next_term = @head.field_terms.create(:start_date=>@date_2_orig)
      end
      
      it 'when new dates are given' do
        updates = {:current_term=>{:end_date=>@date_1.strftime("%F"), :id=>@current_term.id},
                   :next_term=>{:start_date=>@date_2.strftime("%F"), :id=>@next_term.id} }
        put :update, @params.merge(updates)
        @current_term.reload.end_date.should == @date_1           
        @next_term.reload.start_date.should == @date_2
      end

      it 'of wife as well' do
        updates = {:current_term=>{:end_date=>@date_1.strftime("%F"), :id=>@current_term.id},
                   :next_term=>{:start_date=>@date_2.strftime("%F"), :id=>@next_term.id} }
        @wife = @head.create_wife
        @wife.field_terms.create(:end_date=>Date.today+50, :end_estimated=>true)
        @wife.field_terms.create(:start_date=>Date.today+250)
        put :update, @params.merge(updates)
        @wife.reload.most_recent_term.end_date.should == @date_1           
        @wife.pending_term.start_date.should == @date_2
      end
      
      it 'creates field_term records if needed for head and wife' do
        @head.field_terms.destroy_all
        @wife = @head.create_wife
        updates = {:current_term=>{:end_date=>@date_1.strftime("%F")},
                   :next_term=>{:start_date=>@date_2.strftime("%F")} }
        put :update, @params.merge(updates)
        @head.reload.most_recent_term.end_date.should == @date_1           
        @head.pending_term.start_date.should == @date_2
        @wife.reload.most_recent_term.end_date.should == @date_1           
        @wife.pending_term.start_date.should == @date_2
      end
      
      it 'does not update field_term record if new dates are blank' do
        updates = {:current_term=>{:end_date=>"", :id=>@current_term.id},
                   :next_term=>{:start_date=>"", :id=>@next_term.id} }
        put :update, @params.merge(updates)
        @head.reload.most_recent_term.end_date.should == @date_1_orig           
        @head.pending_term.start_date.should == @date_2_orig
      end
        
      it 'does not update field_term record if form did not change dates' do
        # Update params are the same 
        @wife = @head.create_wife
        updates = {:current_term=>{:end_date=>@date_1_orig.strftime("%F")},
                   :next_term=>{:start_date=>@date_2_orig.strftime("%F")} }
        put :update, @params.merge(updates)
        @wife.field_terms.should be_empty # because the head's term dates were not changed by the form
      end
          
        
    end #     'updates field term dates'
           
  end # updating a family

  describe 'same_date' do
    before(:each) do
      @date_1 = Date.new(1999,1,1)
      @date_2 = @date_1+1
      @date_1_str = @date_1.to_s(:default)
      @date_2_str = @date_2.to_s(:default)
    end
    
    it 'is false when object does not exist and new date exists' do
      term=nil
      controller.same_date(term, @date_1_str, :end_date).should be_false
    end
    it 'is false when object.method does not exist and new date exists' do
      term=FieldTerm.new
      controller.same_date(term, @date_1_str, :end_date).should be_false
    end
    it 'is true when object.method does not exist and new date is blank' do
      term=FieldTerm.new
      controller.same_date(term, '', :end_date).should be_true
    end
    it 'is true when object does not exist and new date is blank' do
      term=nil
      controller.same_date(term, '', :end_date).should be_true
    end
    it 'is false when object.method exists but is different from new date' do
      term=FieldTerm.new(:end_date=>@date_2)
      controller.same_date(term, @date_1_str, :end_date).should be_false
    end      
    it 'is true when object.method exists and is same as new date' do
      term=FieldTerm.new(:end_date=>@date_1)
      controller.same_date(term, @date_1_str, :end_date).should be_true
    end      
    it 'is true when date is same though format is different' do
      term=FieldTerm.new(:end_date=>@date_1)
      controller.same_date(term, @date_1.to_s(:int_long), :end_date).should be_true
      controller.same_date(term, @date_1.to_s(:us_long), :end_date).should be_true
    end      

  end 
end
