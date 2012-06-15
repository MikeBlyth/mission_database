require 'spec_helper'

describe Message do
    before(:each) do
      @message = Message.new(:body=>'test message')
      @message.stub(:created_at).and_return(Time.now)
    end

  describe 'initialization' do
    
    it 'sets defaults' do
      m = Message.new
      m.retries.should_not be_nil
      m.confirm_time_limit.should_not be_nil
      m.retry_interval.should_not be_nil
      m.expiration.should_not be_nil
      m.response_time_limit.should_not be_nil
      m.importance.should_not be_nil
      # The names or actual settings might get changed here, so this test may be modified   
    end     
    
  end # initialization

  describe 'to_groups field' do
    
    it 'is changed from param array to string' do
      @message.to_groups = ["1", "4"]
      @message.convert_groups_to_string
      @message.to_groups.should == "1,4"
    end          

    it 'is changed from string to integer array' do
      @message.to_groups = "1,4"
      @message.to_groups_array.should == [1,4]
    end

    it 'is stored as string when saved' do
      Message.stub(:save).and_return(true)
      @message.stub(:deliver).and_return(true)
      @message.send_email = true
      @message.to_groups = ["1", "4"]
      @message.save
      @message.should be_valid
      @message.to_groups.should == "1,4"
    end

  end # to_groups field
            
  describe 'member selection:' do
    it 'excludes members who are not on the field' do
      @contact = Factory.stub(:contact)
      @on_field = Factory.stub(:member)
      @on_field.stub(:primary_contact).and_return(@contact)
      @off_field = Factory.stub(:member)
      Group.stub(:members_in_multiple_groups).and_return([@on_field, @off_field])
      Member.stub(:those_in_country).and_return([@on_field])
      @message.to_groups = '1'
      @message.deliver   
      @message.members.should == [@on_field]
    end      
  end #member selection

  class MockClickatellGateway < ClickatellGateway
    # Used for testing
    attr_accessor :mock_response
    
    def initialize(response='')
      super()
      @mock_response = response
    end
    
    def call_gateway
      return @mock_response
    end  
  end

  describe 'delivers to gateways' do
    after(:each) do
      silence_warnings{ Notifier=@old_notifier }
    end
      
    before(:each) do
      @email = mock('Email', :deliver=>nil)
      # *** Mock the email generator, Notifier ***
      @old_notifier = Notifier
      silence_warnings{ Notifier = mock('Notifier', :send_generic => @email) }
      # *** Message ***
      @member = Factory.stub(:member)
      @contact = Factory.stub(:contact)
      @member.stub(:primary_contact).and_return(@contact)
      Member.stub(:those_in_country).and_return([@member])
      @message = Message.new(:body=>'test message', :to_groups=>"1",
        :retries=>0, :send_email=>nil, :send_sms=>nil)
      @message.stub(:timestamp).and_return('09Jul0545p')
      # *** Gateway ****
      @gw_msg_id = '74958a4f4c328c5bd4a988dfb5a0670c'
      @gw_reply = "ID: #{@gw_msg_id}"
      @gateway = MockClickatellGateway.new(@gw_reply)
      end
    
    it "Sends an email" do
      @message.stub(:send_email).and_return(true)
      Notifier.should_receive(:send_generic).with([@contact.email_1], @message.body)
      @message.deliver
    end

  end # deliver

end
