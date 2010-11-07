require 'test_helper'

class StatusControllerTest < ActionController::TestCase
  setup do
    @status = statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create status" do
# first try should fail to add record because we're adding a duplicate record (:one), and
# the status and _description are unique values
    assert_difference('Status.count',0) do
      post :create, :status => @status.attributes
    end

# now change the status code and try again
    @status_new = statuses(:one)
    @status_new.code = 551555
    @status_new.description = 'new'
    assert_difference('Status.count',1) do
      post :create, :status => @status_new.attributes
    end

    assert_redirected_to status_path(assigns(:status))
  end

  test "should show status" do
    get :show, :id => @status.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @status.to_param
    assert_response :success
  end

  test "should update status" do
    put :update, :id => @status.to_param, :status => @status.attributes
    assert_redirected_to status_path(assigns(:status))
  end

  test "should destroy status" do
    assert_difference('Status.count', -1) do
      delete :destroy, :id => @status.to_param
    end

    assert_redirected_to statuses_path
  end
end
