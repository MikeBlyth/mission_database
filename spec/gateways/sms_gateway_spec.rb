require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'

describe SmsGateway do

  it 'initializes successfully' do
    SmsGateway.new
  end

  it 'stores number and body when specified in send' do
    gateway = SmsGateway.new
    gateway.send('+2347777777777', 'test message')
    gateway.number.should == '+2347777777777'
    gateway.body.should == 'test message'
  end
end

describe ClickatellGateway do
  it 'initializes successfully' do
    gateway = ClickatellGateway.new
    gateway.status[:errors].should be_nil
  end
  
  it 'gives error when parameter is missing' do
    SiteSetting.stub(:clickatell_user_name).and_return(nil)
    gateway = ClickatellGateway.new
    gateway.status[:errors].should_not be_nil
    gateway.status[:errors][0].should match('user_name')
  end
end
