require 'test_helper'

class EducationControllerTest < ActionController::TestCase
  setup do
    @education = educations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:educations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create education" do
# first try should fail to add record because we're adding a duplicate record (:one), and
# the education and _description are unique values
    assert_difference('Education.count',0) do
      post :create, :education => @education.attributes
    end

# now change the education code and try again
    @education_new = educations(:one)
    @education_new.code = 551555
    @education_new.description = 'new'

    assert_difference('Education.count',1) do
      post :create, :education => @education_new.attributes
    end
    assert_redirected_to education_path(assigns(:education))
  end

  test "should show education" do
    get :show, :id => @education.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @education.to_param
    assert_response :success
  end

  test "should update education" do
    put :update, :id => @education.to_param, :education => @education.attributes
    assert_redirected_to education_path(assigns(:education))
  end

  test "should destroy education" do
    assert_difference('Education.count', -1) do
      delete :destroy, :id => @education.to_param
    end

    assert_redirected_to educations_path
  end
end
