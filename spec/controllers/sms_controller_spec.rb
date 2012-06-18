#require 'spec_helper'
#include SimTestHelper
#include ApplicationHelper
include MessagesTestHelper  

describe SmsController do
# Incoming SMS Text Messages

  before(:each) do
    HTTParty = mock('HTTParty').as_null_object if HTTParty.class == Module
    HTTParty.stub(:get).and_return '200'

    # Target -- the person being inquired about in info command
    @target = Factory.stub(:member, :last_name=>'Target')  # Request is going to be for this person's info
    @sender = mock_model(Member)
    @from = '+2348030000000'  # This is the number of incoming SMS
    @body = "info #{@target.last_name}"
    @params = {:From => @from, :Body => @body}
    AppLog = double('AppLog').as_null_object if AppLog.superclass == ActiveRecord::Base  # as_null_object stops it from complaining about unexpected messages
  end

  describe 'logging' do

    describe 'accepted messages' do
      before(:each) do
       # Contact.stub(:find_by_phone_1).and_return(true)
       Member.stub(:find_by_phone).and_return(@sender)
      end
      
      it 'creates a log entry for SMS received' do
        AppLog.should_receive(:create).with({:code => "SMS.received", :description=>"from #{@from}: #{@body}"})
        post :create, @params
      end      

      it 'creates a log entry for response' do
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.reply"))
        post :create, @params
      end      
    end
    
    describe 'rejected messages' do
      it 'creates a log entry for rejected incoming SMS' do
        Contact.stub(:find_by_phone_1).and_return(false)
        Contact.stub(:find_by_phone_2).and_return(false)
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.rejected"))
        post :create, @params
      end
    end      

  end # logging
  
  describe 'filters based on member status' do

    it 'accepts sms from SIM member (using phone_1)' do
      Member.stub(:find_by_phone).and_return(@sender)
      post :create, @params
      response.status.should == 200
    end
    
    it 'rejects sms from strangers' do
      Member.stub(:find_by_phone).and_return(nil)
      post :create, @params
      response.status.should == 403
    end

  end # it filters ...


  describe 'handles these commands:' do
    before(:each) do
      controller.stub(:from_member).and_return(Member.new)   # Just a shortcut to have a contact record that matches from line
    end      

    describe "'info'" do

      describe 'when target name not found' do
        it "gives error message" do
          Member.stub(:find_with_name).and_return([])
          @params[:Body] = "info stranger"
          post :create, @params
          response.body.should =~ /no.*found/i      
          response.body.should =~ /stranger/i      
        end
      end

      describe 'when name found and' do  # record for requested name is found
        before(:each) do
          @last_name = "Abcde"
          residence_location = Factory.stub(:location, :description=>'Rayfield')
          work_location = Factory.stub(:location, :description=>'Spring of Life')
          @target = Factory.stub(:member, :last_name=>@last_name,
                       :birth_date => Date.new(1980,6,15),
                       :work_location=>work_location,
                       :temporary_location => 'Miango Resort Hotel',
                       :temporary_location_from_date => Date.today - 10.days,
                       :temporary_location_until_date => Date.today + 2.days,
                       )
          @contact=Factory.stub(:contact, :member=>@target, :phone_2=>"+2348079999999", :email_2 => 'something@example.com')
          @target.stub(:primary_contact).and_return(@contact)
          @params[:Body] = "info #{@last_name}"
          Member.stub(:find_with_name).and_return([@target])
        end
                          
        it 'returns error for unrecognized command' do
          @params['Body'] = "xxxx #{@last_name}"
          post :create, @params
          response.body.should =~ Regexp.new(@last_name)
          response.body.should =~ /unknown .*xxxx/i
        end
        
        describe 'no contact record found' do
          it "sends basic info" do
            @target.stub(:primary_contact).and_return(nil)
            post :create, @params
            response.body.should =~ Regexp.new(@last_name)
            response.body.should =~ /no contact/i
            response.body.should match Regexp.escape(@target.current_location)
          end
        end

        describe 'contact record found' do

          it "sends contact info and location" do
            post :create, @params
            response.body.should match @last_name
            response.body.should match Regexp.escape(@contact.phone_1.phone_format)
            response.body.should match Regexp.escape(@contact.phone_2.phone_format)
            response.body.should match Regexp.escape(@contact.email_1)
            response.body.should_not match Regexp.escape(@contact.email_2)
              # have to escape the parens in the current location string 
            response.body.should match Regexp.escape(@target.current_location)
          end

          it 'does not send phone number if marked as private' do
            @contact.phone_private=true
            post :create, @params
            response.body.should match Regexp.escape(@contact.email_1)
            response.body.should_not match Regexp.escape(@contact.phone_1.phone_format)
            response.body.should_not match Regexp.escape(@contact.phone_2.phone_format)
          end

          it 'does not send email if marked as private' do
            @contact.email_private=true
            post :create, @params
            response.body.should match Regexp.escape(@contact.phone_1.phone_format)
            response.body.should_not match Regexp.escape(@contact.email_1)
            response.body.should_not match Regexp.escape(@contact.email_2)
          end

        end # when contact info is available

      end # when name and

      it 'limits response length to 160 chars' do
        @params['Body'] = "info #{'a'*170}"
        post :create, @params
        response.body.length.should < 161
      end     

    end # 'info sends contact info'

    describe 'd (group deliver)' do
      before(:each) do
        @group_name = 'testgroup'
        @body = 'xtest messagex'
        @group = Factory(:group, :group_name=>@group_name)
        @params['Body'] = "d #{@group_name} #{@body}"
        @message = Message.new
        Message.stub(:new)
      end
      
      describe 'when group is found' do
        
        it 'delivers a group message if group is found' do
          Message.should_receive(:new).with(hash_including(
              :send_email=>true, :send_sms=>true, :to_groups=>@group.id, :body=>@body))          
          post :create, @params   # i.e. sends 'd testgroup test message'
        end
      end # 'when group is found'
      
    end # d (group deliver)
          

  end # 'handles these commands:'

end
