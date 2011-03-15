require 'spec_helper'

def deny_all
  deny_edit
  deny_update
  deny_show
  deny_destroy
end
  
def deny_edit
  it "should deny access to 'edit'" do
    get :edit, :id => @user
    response.should redirect_to(signin_path)
  end
end      

def deny_update
  it "should deny access to 'update'" do
    put :update, :id => @user, :user => {}
    response.should redirect_to(signin_path)
  end
end      

def deny_show
  it "should deny access to 'show'" do
    get :show, :id => @user
    response.should redirect_to(signin_path)
  end
end      

def deny_destroy
  it "should deny access to 'destroy'" do
    put :destroy, :id => @user
    response.should redirect_to(signin_path)
  end
end      

describe UsersController do
  render_views
  
  before(:each) do
    @user = Factory(:user, :admin => true)
    test_sign_in(@user)
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
#    it "should have the right title" do
#      get 'new'
#      response.should have_selector("title", :content => "New user")
#    end
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
  end

  describe "POST 'create'" do

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end

      it "should redirect to the user show response" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end    

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /success/i
      end

    end

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

#      it "should have the right title" do
#        post :create, :user => @attr
#        page.should have_selector("title", :content => "Sign up")
#      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end
  end

  describe "GET 'edit'" do

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

#    it "should have the right title" do
#      get :edit, :id => @user
#      page.should have_selector("title", :content => "Edit user")
#    end

  end # describe "GET 'edit'" do

  describe "PUT 'update'" do

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

#      it "should have the right title" do
#        put :update, :id => @user, :user => @attr
#        page.should have_selector("title", :content => "Edit user")
#      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end

      it "does not require entering a new password" do
        @attr[:password] = ''
        @attr[:password_confirmation] = ''
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end
    end
  end # describe "PUT 'update'" do
  
  describe "sign in" do
      before(:each) {test_sign_out}

    it "signs the user out" do
      controller.should_not be_signed_in  # since test_sign_out called in before(:each)
    end        

    it "does not sign in user with wrong password" do
      @user.update_attribute(:password, "wrong password")
      controller.should_not be_signed_in
    end

    it "does not sign in with sql injection" do
      @user.update_attribute(:password, "fakepass' OR 'a' = 'a")
      controller.should_not be_signed_in
    end      

  end

  # Check that access to controller is blocked when user is not logged in (use deny_access method defined in spec_helper)
  # "authentication before controller access"
  describe "authentication before controller access" do

    describe "for non-signed-in users" do
      before(:each) {test_sign_out}
      deny_edit
      deny_update
      deny_show
      deny_destroy
    end

    describe "for signed-in, non-administrator users" do

      before(:each) do
        wrong_user = Factory(:user, :name => "Different user", :admin => false)
        test_sign_in(wrong_user)
      end

      # One (ordinary) user should not be able to edit another user's information
      it "should reject non-matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should reject non-matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end # describe "for signed-in users" 

    # Administrator should be able to edit anyone's data
    describe "for administrator users" do

      before(:each) do
        admin_user = Factory(:user, :name => "Different user", :admin => true)
        test_sign_in(admin_user)
      end

      it "should accept admin users for 'edit'" do
        get :edit, :id => @user
        response.should_not redirect_to(root_path)
      end

      it "should accept admin users for 'update'" do
        new_email = "new_email@example.com"
        put :update, :id => @user, :user => @user.attributes.merge(:email => new_email)
        @user.reload
        @user.email.should == new_email
      end
    end # describe "for administrator users" 
  end # describe "authentication before controller access"

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access and redirect to sign-in" do
        test_sign_out
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user deleting another user" do
      it "should not delete the user but redirect to root" do
        test_sign_in(Factory(:user))
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do

      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end # describe "as an admin user"
  end # describe "DELETE 'destroy'"

end
