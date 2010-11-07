require 'test_helper'

class CitiesControllerTest < ActionController::TestCase
  setup do
    @city = cities(:one)
    @controller = CitiesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
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

  test "should create city" do
    assert_difference('City.count') do
      post :create, :record => @city.attributes
    end
  end

  test "should show city" do
    get :show, :id => @city.to_param
    assert_response :success
    assert_template 'show_form'
  end

  test "should get edit" do
    get :edit, :id => @city.to_param
    assert_response :success
    assert_template 'update_form'
  end

  test "should update city" do
    put :update, :id => @city.to_param, :record => @city.attributes
    assert_redirected_to cities_path
  end

  test "should destroy city" do
    assert_difference('City.count', -1) do
      delete :destroy, :id => @city.to_param
    end
    assert_redirected_to cities_path
  end
end
  