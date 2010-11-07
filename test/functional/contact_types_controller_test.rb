require 'test_helper'

class ContactTypesControllerTest < ActionController::TestCase
  setup do
    @contact_type = contact_types(:one)
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

  test "should create contact_type" do
# first try should fail to add record because we're adding a duplicate record (:one), and
# the contact_type and _description are unique values
    assert_difference('ContactType.count',0) do
      post :create, :record => @contact_type.attributes
    end
# Don't yet know how to find the error messages as it's different in ActiveScaffold?
#    assert(@contact_type.errors[:description].to_s =~ /taken/,   "Missing or wrong error message for duplicate description") 

# now change the contact_type code and try again
    @contact_type_new = contact_types(:one)
    @contact_type_new.code = 551555
    @contact_type_new.description = 'new'

    assert_difference('ContactType.count',1) do
      post :create, :record => @contact_type_new.attributes
    end

  end

  test "should show contact_type" do
    get :show, :id => @contact_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @contact_type.to_param
    assert_response :success
    assert_template 'update_form'
  end

  test "should update contact_type" do
    put :update, :id => @contact_type.to_param, :record => @contact_type.attributes
    assert_redirected_to "/contact_types"
  end

  test "should destroy contact_type" do
    assert_difference('ContactType.count', -1) do
      delete :destroy, :id => @contact_type.to_param
    end

  end
end
