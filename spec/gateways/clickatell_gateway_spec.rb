require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'

describe ClickatellGateway do

def gateway_session
   @gateway.instance_variable_get(:@session)
end

def gateway_session_set(session)
   @gateway.instance_variable_set(:@session, session)
end

def gateway_uri_set(uri)
   @gateway.instance_variable_set(:@uri, uri)
end

  before(:each) do
    @phones = ['+2347777777777']
    @mock_reply = mock('gatewayReply', :body=>'')  # Remember to add stubs for body when something expected
  end

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
      if @gateway.errors
        puts "*** Errors in gateway initialization may be caused by 'cleaned' initialization"
        puts "*** parameters. Try restarting Spork before looking for other errors."
      end
      @gateway.errors.should be_nil
      @gateway.gateway_name.should == 'clickatell'  # this is defined by ClickatellGateway#initialize
    end
    
  end # 'when needed parameters are present

  describe 'Handles sessions:' do
    before(:each) do
      @gateway = ClickatellGateway.new
      @session = 'eixktixyiis32kx00l'
    end
    
    it 'gets a session' do
      HTTParty.stub_chain(:get, :body).and_return("OK: #@session")
      @gateway.get_session.should == @session
      @gateway.instance_variable_get(:@session).should == @session
    end

    it 'returns error' do
      response = mock('reply', :body=>'Err: 001, Authentication Failed')
      HTTParty.stub(:get).and_return(response)
      @gateway.get_session.should == response.body
      gateway_session.should be_nil
    end
  end # Handles sessions
  
  describe 'Connects to gateway' do
    before(:each) do
      @gateway = ClickatellGateway.new
      @httyparty = HTTParty
      silence_warnings{HTTParty = mock('HTTParty')}
     end
    after(:each) do
      silence_warnings{ HTTParty = @httyparty }  # Restore normal 
    end
    
    it 'with basic authentication' do
      test_uri = "http://etc/?password=and_so_on"
#      @gateway.instance_variable_set(:@uri, test_uri)
      gateway_uri_set(test_uri)
      HTTParty.should_receive(:get).with(test_uri)
      @gateway.call_gateway
      gateway_session.should be_nil
    end

    it 'with a valid session' do
      test_uri = "http://etc/do_something?blahblahblah"
      gateway_uri_set(test_uri)
      gateway_session_set('dummy')
      @mock_reply.stub(:body).and_return('Fine')
      HTTParty.should_receive(:get).with(test_uri+"&session_id=dummy").and_return(@mock_reply)
      @gateway.call_gateway
    end
  end
      
    
      

  describe 'Deliver method sends messages' do
      before(:each) do
        @gateway = ClickatellGateway.new
        @httyparty = HTTParty
        silence_warnings{HTTParty = mock('HTTParty')}
        @mock_gateway_reply = mock('reply', :body=>"ID: ABCDEF")
        HTTParty.stub(:get).and_return @mock_gateway_reply
        HTTParty.should_receive(:get)
      end
      after(:each) do
        silence_warnings{ HTTParty = @httyparty }  # Restore normal 
      end

    describe 'for single phone number' do
      # Maybe this before(:each) should be refactored? It's funny to have the test going on there, but it's not
      # DRY if we put the mock & message expectation in the individual tests ...

      it 'forms URI properly' do
        @gateway.deliver(@phones, 'test message')
        uri = @gateway.uri
        uri.should match("user=#{SiteSetting.clickatell_user_name}")
        uri.should match("password=#{SiteSetting.clickatell_password}") 
        uri.should match("api_id=#{SiteSetting.clickatell_api_id}")
        uri.should match("to=2347777777777")
        uri.should match("text=#{URI.escape('test message')}")
      end

      it "forms URI phone number string when number doesn't start with a +" do
        @gateway.deliver('1234567890', 'test message')
        @gateway.uri.should match("to=1234567890")
      end

      it 'sets @gateway_reply variable' do
        @gateway.deliver(@phones, 'test message')
        @gateway.gateway_reply.should == @mock_gateway_reply
      end        

      it 'gives @gateway_reply as return value' do
        @gateway.deliver(@phones, 'test message').should == @mock_gateway_reply
      end        

    end # for single phone number

    describe 'for multiple phone numbers' do
      before(:each) do
        @phones = ['+2347777777777', '+2348888888888']
      end

      it 'forms URI properly' do
        @gateway.deliver(@phones, 'test message')
        uri = @gateway.uri
        uri.should match("user=#{SiteSetting.clickatell_user_name}")
        uri.should match("password=#{SiteSetting.clickatell_password}") 
        uri.should match("api_id=#{SiteSetting.clickatell_api_id}")
        uri.should match("to=2347777777777,2348888888888")
        uri.should match("text=#{URI.escape('test message')}")
      end

      it 'forms URI phone list from string' do
        @gateway.deliver(@phones.join(', '), 'test message')
        uri = @gateway.uri
        uri.should match("to=2347777777777,2348888888888")
      end

      it 'sets @gateway_reply variable' do
        @gateway.deliver(@phones, 'test message')
        @gateway.gateway_reply.should == @mock_gateway_reply
      end        

      it 'gives @gateway_reply as return value' do
        @gateway.deliver(@phones, 'test message').should == @mock_gateway_reply
      end        

    end # for multiple phone number

  end # deliver method
end
