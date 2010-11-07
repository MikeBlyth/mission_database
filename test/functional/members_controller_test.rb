require 'test_helper'

class MembersControllerTest < ActionController::TestCase
  setup do
    @member = members(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:members)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create member" do
# first try should fail to add record because we're adding a duplicate record (:one), 
# the spouse is a unique value
    assert_difference('Member.count',0) do
      post :create, :member => @member.attributes
    end
    
# now change the spouse_id and try again    
    @member_new = @member
    @member_new.spouse_id = nil
    assert_difference('Member.count',1) do
      post :create, :member => @member_new.attributes
    end
    
    assert_redirected_to member_path(assigns(:member))
  end

  test "should set family id if 0 or nil" do
    @member = Member.new(:last_name=>'checksingle', :first_name=>'b', :sex=>'m', :country_id=>1)
    @member.family_id = nil
     @member.spouse_id = nil
        assert_difference('Member.count',1, "record not saved with family_id=nil") do
      post :create, :member => @member.attributes
      assert_equal(@member.family_id,@member.id)
    end
  end  
    
  test "should set family id to husband" do
    @wife = Member.new(:last_name=>'spousecheck', :first_name=>'b', :sex=>'f', :country_id=>1)
    @wife.family_id = 0
    @wife.spouse_id = 3
    assert_difference('Member.count',1, "record not saved with family_id=0") do
      post :create, :member => @wife.attributes
    end
    # Have to get wife now from the database in order to get the id number
    @wife = Member.find(:first, :conditions=>["last_name = 'spousecheck'"])
    assert_equal(@wife.spouse_id,@wife.family_id, "family id not automatically set to husband")
    @husband = Member.find(@wife.spouse_id)
    assert_equal(@husband.spouse_id,@wife.id,"Husband's spouse not set to wife")
  end  
    
  test "should show member" do
    get :show, :id => @member.to_param
    assert_response :success
  end
  
  test "should show member without details" do
    # create a new member without a personnel_details record, try to display it 
    # (Can't get this to work with fixture, so adjust the attributes as needed to
    #  get a valid record with no id, and save it)
    memb = Member.new(:last_name=>'a', :first_name=>'b', :family_id=>1, :country_id=>1,
        :sex=>'m')
    assert(memb.save,"Couldn't save member to test it!")
    assert(memb.id,"#{memb.attributes.to_s}")
    get :show, :id => memb.to_param
    assert_response :success, "#{memb.attributes.to_s}"
  end
  

  test "should get edit" do
    get :edit, :id => @member.to_param
    assert_response :success
  end

  test "should update member" do
    put :update, :id => @member.to_param, :member => @member.attributes
    assert_redirected_to member_path(assigns(:member))
  end

  test "should destroy member" do
    assert_difference('Member.count', -1) do
      delete :destroy, :id => @member.to_param
    end

    assert_redirected_to members_path
  end
end
