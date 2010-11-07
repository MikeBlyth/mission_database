require 'test_helper'

class StatesControllerTest < ActionController::TestCase
  setup do
    @state = states(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:states)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create state" do
# first try should fail to add record because we're adding a duplicate record (:one), and
# the state_name and are unique values
    assert_difference('State.count',0) do
      post :create, :state => @state.attributes
    end

# now change the state code and try again
    @state_new = states(:one)
    @state_new.name = 'new'

    assert_difference('State.count',1) do
      post :create, :state => @state_new.attributes
    end

    assert_redirected_to state_path(assigns(:state))
  end

  test "should show state" do
    get :show, :id => @state.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @state.to_param
    assert_response :success
  end

  test "should update state" do
    put :update, :id => @state.to_param, :state => @state.attributes
    assert_redirected_to state_path(assigns(:state))
  end

  test "should destroy state" do
    assert_difference('State.count', -1) do
      delete :destroy, :id => @state.to_param
    end

    assert_redirected_to states_path
  end
end
