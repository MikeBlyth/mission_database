require 'spec_helper'

describe "Users" do
  describe "by Administrator" do

    before(:each) { integration_test_sign_in(:admin=>true)}

    describe "creating new user" do

      describe "failure" do

        it "should not create a new user with missing values" do
          lambda do
            visit new_user_path
# save_and_open_response( )
            fill_in "Name",         :with => ""
            fill_in "Email",        :with => ""
            fill_in "Password",     :with => ""
            fill_in "Confirmation", :with => ""
            click_button "user_submit"
#            page.should have_content("Email can't be blank")
            response.should contain("Email can't be blank")
            response.should contain("Name can't be blank")
            response.should contain("Email is invalid")
            response.should contain("Password can't be blank")
            response.should contain("too short")
          end.should_not change(User, :count)
        end # it should
      end #failure

      describe "success" do
        it "should create a new user with good values" do
          lambda do
            visit new_user_path
            fill_in "Name",         :with => "Example User"
            fill_in "Email",        :with => "user@example.com"
            fill_in "Password",     :with => "foobar"
            fill_in "Confirmation", :with => "foobar"
            click_button "Create"
            response.should have_selector("div.flash.success",
                                          :content => "Successfully")
          end.should change(User, :count).by(1)
        end #it should
      end # Describe success
    end # Creating New User

    it "edit form should not have field for Admin privileges" do
      visit edit_user_path @user
      response.should contain("Edit User")
      response.should_not contain("Administrator")
    end

  end # by Administrator 

  describe "by Non-administrator" do
    before(:each) { integration_test_sign_in(:admin=>false)}

    it "should not create a new user even with good values" do
      visit new_user_path @user
      response.should have_selector("title", :content => "SIM")
      response.should have_selector("div.flash.alert")
    end

    it 'should allow user to edit his own record' do
      pending
    end

  end # "by Non-administrator"

  describe "sign in/out" do

    describe "failure" do
      it "should not sign a user in with missing values" do
        visit signin_path
        fill_in "Name",    :with => ""
        fill_in "Password", :with => ""
        click_button "Sign in"
        response.should have_selector("div.flash.error", :content => "Invalid")
      end
    end #failure

    describe "success" do
      it "should sign a user in and out with right values" do
       user = Factory(:user)
        visit signin_path
        fill_in "Name",    :with => user.name
        fill_in "Password", :with => user.password
        click_button "Sign in"
        response.should have_selector("a", :content => "Sign out")
        click_link "Sign out"
        response.should have_selector("a", :content => "Sign in")
      end
    end #success
  end # sign in/out

end
