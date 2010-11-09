require 'spec_helper'

describe JqueriesController do

  def mock_jquery(stubs={})
    (@mock_jquery ||= mock_model(Jquery).as_null_object).tap do |jquery|
      jquery.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all jqueries as @jqueries" do
      Jquery.stub(:all) { [mock_jquery] }
      get :index
      assigns(:jqueries).should eq([mock_jquery])
    end
  end

  describe "GET show" do
    it "assigns the requested jquery as @jquery" do
      Jquery.stub(:find).with("37") { mock_jquery }
      get :show, :id => "37"
      assigns(:jquery).should be(mock_jquery)
    end
  end

  describe "GET new" do
    it "assigns a new jquery as @jquery" do
      Jquery.stub(:new) { mock_jquery }
      get :new
      assigns(:jquery).should be(mock_jquery)
    end
  end

  describe "GET edit" do
    it "assigns the requested jquery as @jquery" do
      Jquery.stub(:find).with("37") { mock_jquery }
      get :edit, :id => "37"
      assigns(:jquery).should be(mock_jquery)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created jquery as @jquery" do
        Jquery.stub(:new).with({'these' => 'params'}) { mock_jquery(:save => true) }
        post :create, :jquery => {'these' => 'params'}
        assigns(:jquery).should be(mock_jquery)
      end

      it "redirects to the created jquery" do
        Jquery.stub(:new) { mock_jquery(:save => true) }
        post :create, :jquery => {}
        response.should redirect_to(jquery_url(mock_jquery))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved jquery as @jquery" do
        Jquery.stub(:new).with({'these' => 'params'}) { mock_jquery(:save => false) }
        post :create, :jquery => {'these' => 'params'}
        assigns(:jquery).should be(mock_jquery)
      end

      it "re-renders the 'new' template" do
        Jquery.stub(:new) { mock_jquery(:save => false) }
        post :create, :jquery => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested jquery" do
        Jquery.should_receive(:find).with("37") { mock_jquery }
        mock_jquery.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :jquery => {'these' => 'params'}
      end

      it "assigns the requested jquery as @jquery" do
        Jquery.stub(:find) { mock_jquery(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:jquery).should be(mock_jquery)
      end

      it "redirects to the jquery" do
        Jquery.stub(:find) { mock_jquery(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(jquery_url(mock_jquery))
      end
    end

    describe "with invalid params" do
      it "assigns the jquery as @jquery" do
        Jquery.stub(:find) { mock_jquery(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:jquery).should be(mock_jquery)
      end

      it "re-renders the 'edit' template" do
        Jquery.stub(:find) { mock_jquery(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested jquery" do
      Jquery.should_receive(:find).with("37") { mock_jquery }
      mock_jquery.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the jqueries list" do
      Jquery.stub(:find) { mock_jquery }
      delete :destroy, :id => "1"
      response.should redirect_to(jqueries_url)
    end
  end

end
