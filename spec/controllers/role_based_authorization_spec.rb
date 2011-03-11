# Did this come from Nick Hoffman? I can't find the source or description! (Mike Blyth)

require 'spec_helper'
require 'auth_spec_helper'

include AuthSpecHelper

describe UsersController do

  before(:each) do
    @admin_user = Factory(:user, :admin => true)
    test_sign_in(@admin_user)
    @new_user = Factory(:user, :medical=>false, :personnel=>false, :travel=>false, :immigration=>false,
                        :admin=>false)
  end
  
  it "Admin user cannot set roles through 'update'" do
    put :update, :id=>@new_user, :user=>{:medical=>true, :personnel=>true}
    @new_user.reload
    @new_user.medical.should be_false  
    @new_user.personnel.should be_false
  end

  it "Admin user can set roles through 'update_roles" do
    put :update_roles, :id=>@new_user, :user=>{:medical=>true, :personnel=>true}
    @new_user.reload
    @new_user.medical.should be_true  
    @new_user.personnel.should be_true
    @new_user.travel.should be_false
    @new_user.immigration.should be_false
    @new_user.admin.should be_false
  end

  it "Non-Admin user can not set roles" do
    test_sign_out
    test_sign_in(@new_user)  # Not an administrator
    put :update_roles, :id=>@new_user, :user=>{:medical=>true, :personnel=>true}
    @new_user.reload
    @new_user.medical.should be_false  
    @new_user.personnel.should be_false
  end
  
end

describe TravelsController do

end
