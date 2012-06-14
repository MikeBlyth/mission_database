require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'

describe SmsGateway do

  it 'initializes successfully' do
    SmsGateway.new
  end

  it 'stores number and body when specified in send' do
    gateway = SmsGateway.new
    gateway.deliver('+2347777777777', 'test message')
    gateway.number.should == '+2347777777777'
    gateway.body.should == 'test message'
  end
end

describe ClickatellGateway do

  describe 'when needed parameters are missing' do
    before(:each) do
      SiteSetting.stub(:clickatell_user_name).and_return(nil)
      @gateway = ClickatellGateway.new
    end

    it 'gives error when parameter is missing' do
      @gateway.errors.should_not be_nil
      @gateway.errors[0].should match('user_name')
    end

  end # when needed parameters are missing
  
  describe 'when needed parameters are present' do
    before(:each) do
      @gateway = ClickatellGateway.new
    end
          
    it 'initializes successfully' do
      @gateway.errors.should be_nil
      @gateway.gateway_name.should == 'clickatell'  # this is defined by ClickatellGateway#initialize
    end
    
    describe 'Deliver method' do
      # Maybe this before(:each) should be refactored? It's funny to have the test going on there, but it's not
      # DRY if we put the mock & message expectation in the individual tests ...
      before(:each) do
        HTTParty = mock('HTTParty')
        HTTParty.stub(:get).and_return '200'
        HTTParty.should_receive(:get)
      end

      it 'forms URI properly' do
        @gateway.deliver('+2347777777777', 'test message')
        uri = @gateway.uri
        uri.should match("user=#{SiteSetting.clickatell_user_name}")
        uri.should match("password=#{SiteSetting.clickatell_password}") 
        uri.should match("api_id=#{SiteSetting.clickatell_api_id}")
        uri.should match("to=2347777777777")
        uri.should match("text=#{URI.escape('test message')}")
      end

      it 'sets @http_status variable' do
        @gateway.deliver('+2347777777777', 'test message')
        @gateway.http_status.should == '200'
      end        

      it 'gives @http_status as return value' do
        @gateway.deliver('+2347777777777', 'test message').should == '200'
      end        

    end # deliver method
  end # when needed parameters are present
end
