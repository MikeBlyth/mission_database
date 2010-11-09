require "spec_helper"

describe JqueriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/jqueries" }.should route_to(:controller => "jqueries", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/jqueries/new" }.should route_to(:controller => "jqueries", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/jqueries/1" }.should route_to(:controller => "jqueries", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/jqueries/1/edit" }.should route_to(:controller => "jqueries", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/jqueries" }.should route_to(:controller => "jqueries", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/jqueries/1" }.should route_to(:controller => "jqueries", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/jqueries/1" }.should route_to(:controller => "jqueries", :action => "destroy", :id => "1")
    end

  end
end
