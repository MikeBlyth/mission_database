require 'test_helper'

class EmploymentStatusControllerTest < ActionController::TestCase
  setup do
    @employment_status = employment_statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employment_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create employment_status" do
# first try should fail to add record because we're adding a duplicate record (:one), and
# the employment_status and _description are unique values
    assert_difference('EmploymentStatus.count',0) do
      post :create, :employment_status => @employment_status.attributes
    end

# now change the employment_status code and try again
    @employment_status_new = employment_statuses(:one)
    @employment_status_new.code = 551555
    @employment_status_new.description = 'new'

    assert_difference('EmploymentStatus.count',1) do
      post :create, :employment_status => @employment_status_new.attributes
    end

    assert_redirected_to employment_status_path(assigns(:employment_status))
  end

  test "should show employment_status" do
    get :show, :id => @employment_status.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @employment_status.to_param
    assert_response :success
  end

  test "should update employment_status" do
    put :update, :id => @employment_status.to_param, :employment_status => @employment_status.attributes
    assert_redirected_to employment_status_path(assigns(:employment_status))
  end

  test "should destroy employment_status" do
    assert_difference('EmploymentStatus.count', -1) do
      delete :destroy, :id => @employment_status.to_param
    end

    assert_redirected_to employment_statuses_path
  end
end
