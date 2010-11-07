require 'test_helper'

# See http://www.42.mach7x.com/2007/11/08/controller-testing-in-active-scaffold/
# Controller testing in Active Scaffold by Kosmas

class BloodtypesControllerTest < ActionController::TestCase
  setup do
    @bloodtype = bloodtypes(:one)
  end


  test "should get index" do
    get :index
    assert_response :success
    assert_template 'list'
  end
 
  test "should get new" do
    get :new
    assert_response :success
    assert_template 'create_form'
  end

  test "should create bloodtype" do
    @bloodtype.full = "CREATE"
    assert_difference('Bloodtype.count') do
      post :create, :record => @bloodtype.attributes
    end
  end

  test "should not create duplicate bloodtype" do
    assert_difference('Bloodtype.count',0) do
      post :create, :record => @bloodtype.attributes
    end
  end
 
  test "should show bloodtype" do
    get :show, :id => @bloodtype.to_param
    assert_response :success
    assert_template 'show'
  end
 
  test "should get edit" do
    get :edit, :id => @bloodtype.to_param
    assert_response :success
    assert_template 'update_form'
  end

  test "should update bloodtype" do
    put :update, :id => @bloodtype.to_param, :record => @bloodtype.attributes
    assert_redirected_to bloodtypes_path
  end

  test "should destroy bloodtype" do
    assert_difference('Bloodtype.count', -1) do
      delete :destroy, :id => @bloodtype.to_param
    end

    assert_redirected_to bloodtypes_path
  end
end

=begin
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bloodtypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

# first try should fail to add record because we're adding a duplicate record (:one), and
# the bloodtype_full is a unique value
  test "should not create duplicate bloodtype" do
    assert_equal(@bloodtype.full,"A-")
    assert_difference('Bloodtype.count',0) do
      post :create, :record => @bloodtype.attributes
    end
  end
  
# now change the *full* attribute and try again
  test "should create different bloodtype" do
    @bloodtype_new = bloodtypes(:one)
    @bloodtype.full = "something else"

    assert_difference('Bloodtype.count',1) do
      post :create, :record => @bloodtype_new.attributes
    end
#    assert_redirected_to bloodtype_path(assigns(:bloodtype))
  end

  test "should show bloodtype" do
    get :show, :id => @bloodtype.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @bloodtype.to_param
    assert_response :success
  end

  test "should update bloodtype" do
    put :update, :id => @bloodtype.to_param, :record => @bloodtype.attributes
    assert_redirected_to bloodtype_path(assigns(:bloodtype))
  end

  test "should destroy bloodtype" do
    assert_difference('Bloodtype.count', -1) do
      delete :destroy, :id => @bloodtype.to_param
    end

    assert_redirected_to bloodtypes_path
  end
end
=end
