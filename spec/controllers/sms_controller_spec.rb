#require 'spec_helper'
#include SimTestHelper
#include ApplicationHelper
#  
describe SmsController do
  before(:each) do
    @member = Factory(:member)
    @params = {
             :From => '+2348030000000',
             :Body => @member.last_name
             }
  end

  describe 'filters based on member status' do

    it 'creates a CalendarEvent for testing' do
      post :create, @params
      CalendarEvent.last.event.should =~ /Received sms/i
puts CalendarEvent.last.event
    end      

    it 'accepts sms from SIM member (using phone_1)' do
      @contact = Factory(:contact, :phone_1 => @params[:From])  # have a contact record that matches from line
#@params[:body] = 'xxx'
      post :create, @params
      response.status.should == 200
puts response.body
    end
    
    it 'accepts sms from SIM member (using phone_2)' do
      @contact = Factory(:contact, :phone_2 => @params[:From])  # have a contact record that matches from line
      post :create, @params
      response.status.should == 200
    end
    
    it 'accepts sms from SIM member (stubbed)' do
      controller.stub(:from_member).and_return(Member.new)  # have a contact record that matches from line
      post :create, @params
      response.status.should == 200
    end
    
    it 'rejects sms from strangers' do
      @contact = Factory(:contact, :phone_1=> '2345')  # have a contact record that matches from line
      post :create, @params
      response.status.should == 403
    end

  end # it filters ...


end
