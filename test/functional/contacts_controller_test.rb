require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  setup do
    @contact = contacts(:one)
  end

  test "should get index" do
#puts " INDEX ***Contact.attributes #{@contact.attributes}"
    get :index
    assert_response :success
    assert_template 'list'
   Member.find(:all).each do |m| puts "#{m.id}, #{m.full_name}" end
  end

  test "should get new" do
#puts " GET NEW ***Contact.attributes #{@contact.attributes}"
    get :new
    assert_response :success
    assert_template 'create'
  end

  test "should create contact" do
    @contact.id = nil
    @contact.member_id = 1
    @contact.member = Member.find(1)
puts "CREATE ***Contact "
    assert_difference('Contact.count') do
      post :create, :record => @contact.attributes
#puts "***Contact.errors #{@contact.errors}"
    end
    assert_redirected_to contacts_path
  end
  
# FUNCTIONALITY OF THIS NOW HANDLED BY UNIT TEST
  #test "should not accept bad member id" do
  # Should not add a contact without a matching member id
#    @contact_new = contacts(:one)
#    @contact_new.member_id = 9995
#    assert_equal(@contact_new.member_id,9995)
#    assert_difference('Contact.count',0) do
#      post :create, :contact => @contact_new.attributes
#    end

#  end

  test "should show contact" do
    get :show, :id => @contact.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @contact.to_param
    assert_response :success
    assert_template 'update'
  end

#  test "should update contact" do
#    put :update, :id => @contact.to_param, :record => @contact.attributes
#    assert_redirected_to contacts_path
#  end

  test "should destroy contact" do
    assert_difference('Contact.count', -1) do
      delete :destroy, :id => @contact.to_param
    end

    assert_redirected_to contacts_path
  end
end
