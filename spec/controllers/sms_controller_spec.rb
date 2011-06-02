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
    end      

    it 'accepts sms from SIM member (using phone_1)' do
      @contact = Factory(:contact, :phone_1 => @params[:From])  # have a contact record that matches from line
#@params[:body] = 'xxx'
      post :create, @params
      response.status.should == 200
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


  describe 'handles these commands:' do
    before(:each) do
      controller.stub(:from_member).and_return(Member.new)   # have a contact record that matches from line
      contact_type = Factory(:contact_type)
      @last_name = "Abcde"
    end      
    
    describe 'info sends contact info' do

      it "gives error message if name not found" do
        @params['Body'] = "info stranger"
        post :create, @params
        response.body.should =~ /no.*found/i      
        response.body.should =~ /stranger/i      
      end

      it "sends basic info if contact record not found" do
        member = Factory(:member, :last_name=>@last_name)
        @params['Body'] = "info #{@last_name}"
        post :create, @params
        response.body.should =~ Regexp.new(@last_name)
        response.body.should =~ /no contact/i
      end

      it "sends contact info if available" do
        residence_location = Factory(:location, :description=>'Rayfield')
        work_location = Factory(:location, :description=>'Spring of Life')
        member = Factory(:member, :last_name=>@last_name,
                     :birth_date => Date.new(1980,6,15),
                     :residence_location=>residence_location,
                     :work_location=>work_location,
                     :temporary_location => 'Miango Resort Hotel',
                     :temporary_location_from_date => Date.today - 10.days,
                     :temporary_location_until_date => Date.today + 2.days,
                     )
        contact=Factory(:contact, :member=>member, :phone_2=>"+2348079999999")
        @params['Body'] = "info #{@last_name}"
        post :create, @params
        response.body.should match @last_name
        response.body.should match Regexp.escape(contact.phone_1)
        response.body.should match Regexp.escape(contact.phone_2)
          # have to escape the parens in the current location string 
        response.body.should match Regexp.escape(member.current_location)
      end

      it 'limits response length to 160 chars' do
        @params['Body'] = "info #{'a'*170}"
        post :create, @params
        response.body.length.should < 161
      end     
    end # 'info sends contact info'


  end # 'handles these commands:'

end
