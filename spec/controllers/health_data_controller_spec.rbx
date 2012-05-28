require 'spec_helper'

describe HealthDataController do

# All the controller really does is the list (index). Other actions are not allowed (search may be allowed).  
  describe "authentication before controller access" do

    describe "for signed-in admin users" do
 
      before(:each) do
        @user = Factory(:user, :admin=>true)
        test_sign_in(@user)
      end
      
      it "suspicious requests should route to signout" do
        assert_recognizes({:controller => "sessions", :action => "destroy"}, {:path=>"/health_data/new"} )     
        assert_recognizes({:controller => "sessions", :action => "destroy", :id=>'21'}, {:path=>"/health_data/21"} )     
        assert_recognizes({:controller => "sessions", :action => "destroy", :id=>'21'}, {:path=>"/health_data/21/edit"} )     
        assert_recognizes({:controller => "sessions", :action => "destroy", :method=> 'post'}, {:path=>"/health_data", :method=> :post} )     
        assert_recognizes({:controller => "sessions", :action => "destroy", :id=>'21'}, {:path=>"/health_data/21", :method=> :delete} )     
      end
      
    end # for signed-in users

  end # describe "authentication before controller access"

  # These should probably be put into the member MODEL spec

     
end
