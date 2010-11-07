require 'test_helper'

class MinistryControllerTest < ActionController::TestCase
  setup do
    @ministry = ministrys(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ministrys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ministry" do
# first try should fail to add record because we're adding a duplicate record (:one), and
# the ministry and _description are unique values
    assert_difference('Ministry.count',0) do
      post :create, :ministry => @ministry.attributes
    end

# now change the ministry code and try again
    @ministry_new = ministrys(:one)
    @ministry_new.code = 551555
    @ministry_new.description = 'new'
    assert_difference('Ministry.count',1) do
      post :create, :ministry => @ministry_new.attributes
    end

    assert_redirected_to ministry_path(assigns(:ministry))
  end

  test "should show ministry" do
    get :show, :id => @ministry.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ministry.to_param
    assert_response :success
  end

  test "should update ministry" do
    put :update, :id => @ministry.to_param, :ministry => @ministry.attributes
    assert_redirected_to ministry_path(assigns(:ministry))
  end

  test "should destroy ministry" do
    assert_difference('Ministry.count', -1) do
      delete :destroy, :id => @ministry.to_param
    end

    assert_redirected_to ministrys_path
  end
end
