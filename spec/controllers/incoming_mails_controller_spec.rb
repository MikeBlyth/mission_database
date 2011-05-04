require 'spec_helper'

describe IncomingMailsController do

  describe "responds with appropriate acks" do
    it 'to invalid email' do
      Incoming = double('Incoming', :receive=>false)
      post :create, :message => "From: test@example.com\r\nSubject: New Poster\r\n\r\nContent"
#      y response
      response.status.should == 422
      response.body.should =~ /Error/
    end    

    it 'to valid email' do
      Incoming = double('IncomingMailer', :receive=>true)
      post :create, :message => "From: test@example.com\r\nSubject: New Poster\r\n\r\nContent"
      response.status.should == 201
    end    
  end

end
