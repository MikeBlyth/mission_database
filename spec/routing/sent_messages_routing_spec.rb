require "spec_helper"

describe SentMessagesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/sent_messages" }.should route_to(:controller => "sent_messages", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/sent_messages/new" }.should route_to(:controller => "sent_messages", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/sent_messages/1" }.should route_to(:controller => "sent_messages", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/sent_messages/1/edit" }.should route_to(:controller => "sent_messages", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/sent_messages" }.should route_to(:controller => "sent_messages", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/sent_messages/1" }.should route_to(:controller => "sent_messages", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/sent_messages/1" }.should route_to(:controller => "sent_messages", :action => "destroy", :id => "1")
    end

  end
end
