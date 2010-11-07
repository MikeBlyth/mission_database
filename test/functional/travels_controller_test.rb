require 'test_helper'

class TravelsControllerTest < ActionController::TestCase
  setup do
    @travel = travels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
 puts "******INDEX assigns(:travels) = #{assigns(:travels)} "
    assert_not_nil assigns(:travels)
 end

  test "should get new" do
    get :new
 puts "******NEW assigns(:travels) = #{assigns(:travels)} "
    assert_response :success
  end

  test "should create travel" do
    assert_difference('Travel.count') do
      post :create, :record => @travel.attributes
    end
 puts "************ CREATE assigns(:travels) = #{assigns(:travels)} and again #{assigns(:travels)}"

    assert_redirected_to travel_path(assigns(:travels))
  end

  test "should show travel" do
    get :show, :id => @travel.to_param
 puts "******SHOW assigns(:travels) = #{assigns(:travels)} "
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @travel.to_param
 puts "******EDIT assigns(:travels) = #{assigns(:travels)} "
    assert_response :success
  end

  test "should update travel" do
    put :update, :id => @travel.to_param, :record => @travel.attributes
 puts "******UPDATE assigns(:travels) = #{assigns(:travels)} "
    assert_redirected_to travel_path(assigns(:travel))
  end

  test "should destroy travel" do
    assert_difference('Travel.count', -1) do
      delete "destroy", :id => @travel
 puts "******DESTROY assigns(:travels) = #{assigns(:travels)} "
    end

    assert_redirected_to travels_path
  end
end
