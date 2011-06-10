require 'spec_helper'
include SimTestHelper

describe ContactsController do
  
  before(:each) do
      @user = Factory.stub(:user, :admin=>true)
      test_sign_in(@user)
  end

end
