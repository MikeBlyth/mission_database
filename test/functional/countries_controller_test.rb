require 'test_helper'

class CountriesControllerTest < ActionController::TestCase
  setup do
    @country = countries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:countries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create country" do
# first try should fail to add record because we're adding a duplicate record (:one), and
# the country and _description are unique values
    assert_difference('Country.count',0) do
      post :create, :country => @country.attributes
    end

# now change the country code and try again
    @country_new = countries(:one)
    @country_new.code = 'ZZ'
    @country_new.name = 'new'

    assert_difference('Country.count',1) do
      post :create, :country => @country_new.attributes
    end

    assert_redirected_to country_path(assigns(:country))
  end

  test "should show country" do
    get :show, :id => @country.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @country.to_param
    assert_response :success
  end

  test "should update country" do
    put :update, :id => @country.to_param, :country => @country.attributes
    assert_redirected_to country_path(assigns(:country))
  end

  test "should destroy country" do
    assert_difference('Country.count', -1) do
      delete :destroy, :id => @country.to_param
    end

    assert_redirected_to countries_path
  end
end
