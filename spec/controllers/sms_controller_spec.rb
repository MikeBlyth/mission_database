#require 'spec_helper'
#include SimTestHelper
#include ApplicationHelper
#  
describe SmsController do
  before(:each) do
    @member = Factory(:member)  # Request is going to be for this person's info
    @params = {
             :From => '+2348030000000',  # This is the number of incoming SMS
             :Body => "info #{@member.last_name}"
             }
  end

  describe 'logging' do

    describe 'accepted messages' do
      before(:each) do
        @contact = Factory(:contact, :phone_1 => @params[:From])  # have a contact record that matches from line
      end
      
      it 'creates a log entry for SMS received' do
        post :create, @params
        AppLog.first.code.should =~ /SMS.received/i
        AppLog.first.description.should =~ /23480300000/
      end      

      it 'creates a log entry for response' do
        post :create, @params
        entry = AppLog.find_by_code('SMS.reply')
        entry.description.should =~ /23480300000/
      end      
    end
    
    describe 'rejected messages' do
      it 'creates a log entry for rejected incoming SMS' do
        post :create, @params
        AppLog.find_by_code('SMS.reply').should be_nil
        entry = AppLog.find_by_code('SMS.rejected')
        entry.description.should =~ /23480300000/
      end
    end      

  end # logging
  
  describe 'filters based on member status' do

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

    describe "'info'" do

      describe 'when name not found' do
        it "gives error message" do
          @params['Body'] = "info stranger"
          post :create, @params
          response.body.should =~ /no.*found/i      
          response.body.should =~ /stranger/i      
        end
      end

      describe 'when name found and' do  # record for requested name is found
        before(:each) do
          residence_location = Factory(:location, :description=>'Rayfield')
          work_location = Factory(:location, :description=>'Spring of Life')
          @member = Factory(:member, :last_name=>@last_name,
                       :birth_date => Date.new(1980,6,15),
#*                       :residence_location=>residence_location,
                       :work_location=>work_location,
                       :temporary_location => 'Miango Resort Hotel',
                       :temporary_location_from_date => Date.today - 10.days,
                       :temporary_location_until_date => Date.today + 2.days,
                       )
          @params['Body'] = "info #{@last_name}"
        end
                          
        it 'returns error for unrecognized command' do
          @params['Body'] = "xxxx #{@last_name}"
          post :create, @params
          response.body.should =~ Regexp.new(@last_name)
          response.body.should =~ /unknown .*xxxx/i
        end
        
        describe 'no contact record found' do
          it "sends basic info" do
            post :create, @params
            response.body.should =~ Regexp.new(@last_name)
            response.body.should =~ /no contact/i
            response.body.should match Regexp.escape(@member.current_location)
          end
        end

        describe 'contact record found' do
          before(:each) do
            @contact=Factory(:contact, :member=>@member, :phone_2=>"+2348079999999",
                               :email_2 => 'something@example.com')
          end

          it "sends contact info and location" do
            post :create, @params
            response.body.should match @last_name
            response.body.should match Regexp.escape(@contact.phone_1.phone_format)
            response.body.should match Regexp.escape(@contact.phone_2.phone_format)
            response.body.should match Regexp.escape(@contact.email_1)
            response.body.should_not match Regexp.escape(@contact.email_2)
              # have to escape the parens in the current location string 
            response.body.should match Regexp.escape(@member.current_location)
          end

          it 'does not send phone number if marked as private' do
            @contact.update_attribute(:phone_private, true)
            post :create, @params
            response.body.should match Regexp.escape(@contact.email_1)
            response.body.should_not match Regexp.escape(@contact.phone_1.phone_format)
            response.body.should_not match Regexp.escape(@contact.phone_2.phone_format)
          end

          it 'does not send email if marked as private' do
            @contact.update_attribute(:email_private, true)
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

  end # 'handles these commands:'

end
