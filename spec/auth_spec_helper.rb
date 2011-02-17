# This module provides a method check_authentication which simply checks that a given controller blocks access
# to :new, :edit, :show, :update, and :destroy when a user is not signed in, but allows access when they are
# signed in. Since it's all sort of a modular, single function (authentication), the method does NOT 
# create the object or sign-in the user for each test, it just does them all in sequence. Violates some
# testing principles but keeps things really simple in the spec files. 
module AuthSpecHelper
  def check_authentication(object)
    # First check without signed-in user
    get :new
    response.should redirect_to(signin_path)
    #  it "should deny access to 'edit'" do
    get :edit, :id => object.id
    response.should redirect_to(signin_path)
    # it "should allow access to 'show'" do
    get :show, :id => object.id
    response.should redirect_to(signin_path)
    #  it "should allow access to 'update'" do
    put :update, :id => object.id, :record => object.attributes
    response.should redirect_to(signin_path)
    #  it "should allow access to 'destroy'" do
    # NB: the next line will actually delete the object if it succeeds, and subsequent tests
    #     would then fail, but RSpec will stop anyway after the first failure.
    put :destroy, :id => object.id
    response.should redirect_to(signin_path)
    #
    @user = Factory(:user)
    test_sign_in(@user)
    #
    get :new
    response.should_not redirect_to(signin_path)
    get :edit, :id => object.id
    response.should_not redirect_to(signin_path)
    get :show, :id => object.id
    response.should_not redirect_to(signin_path)
    put :update, :id => object.id, :record => object.attributes
    response.should_not redirect_to(signin_path)
    #  it "should allow access to 'destroy'" do
    # NB: the next line will actually delete the object if it succeeds, which it should,
    #     so this line should be LAST. 
    put :destroy, :id => object.id
    response.should_not redirect_to(signin_path)
    #  it "should allow access to 'update'" do
  end
end
