require 'spec_helper'
require 'mock_clickatell_gateway'
require 'messages_test_helper'
include MessagesTestHelper

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

  it 'returns correct timestamp' do
    message = Message.new(:created_at =>Time.new(2000,07,12,10,14))
    message.timestamp.should == '12Jul1014a'
  end
            
  describe 'generates sent_message records' do
    before(:each) do
      @members = members_w_contacts(2)
      @message = Factory.build(:message, :created_at=>@created_at, :send_email=>true)
    end
    
    it 'excludes members who are not on the field' do
      Member.stub(:those_in_country).and_return([@members[0]])
      @message.save.should be_true   
      @message.members.should == [@members[0]]
    end      

    it 'creates association w recipient members' do
      @message.save
      @message.save.should be_true   
      @message.members.should == @members
    end   

    it 'saves sent_message record for member' do
      @members = members_w_contacts(2, false) # false = "Don't use stubs, use real objects"
      @message.save.should be_true   
      @message.sent_messages.count.should == 2
      @message.sent_messages.each do |sent_message|
        sent_message.member.should_not be_nil
        @members.should include sent_message.member
      end
    end   

  end # generates sent_message records
  
  describe 'delivers to gateways' do
    after(:each) do
      silence_warnings{ Notifier=@old_notifier }
    end
    before(:each) do
      # *** Mock the email generator, Notifier ***
        @email = mock('Email', :deliver=>nil)
        @old_notifier = Notifier
        silence_warnings{ Notifier = mock('Notifier', :send_generic => @email) }
        @old_applog = AppLog
        silence_warnings { AppLog = mock('AppLog').as_null_object }
      # *** Message ***
        @created_at = Time.new(2000,06,07,14,20)
        @message = Factory.build(:message, :created_at=>@created_at)
    end

    describe 'with single addresses' do
      
      before(:each) do
        # Note that in these tests we simply *insert* the members during the test setup,
        # since we have already tested that Message will do that properly. Otherwise we
        # will have to "save" the message first, to trigger the creation of the sent_message
        # records that tie the message to the members.
        # Note that you can't access sent_message records unless they *are* created.
        @members = members_w_contacts(1)
        @message.stub(:members).and_return(@members)  # NB: See above
        @message.stub(:sent_messages).and_return((0..@members.size-1).map{|n| SentMessage.new})
        @gateway = MockClickatellGateway.new(nil,@members)
      end
      
      it "Sends an email" do
        select_media(:email=>true)
        Notifier.should_receive(:send_generic).
          with([@members[0].primary_contact.email_1], @message.body, true)
        @message.deliver
      end

      it "Does not sends an email if it's not selected" do
        select_media(:email=>false)
        Notifier.should_not_receive(:send_generic)
        @message.deliver
      end

      it "Sends an SMS" do
        select_media(:sms=>true)
        @gateway.should_receive(:deliver).with(nominal_phone_number_string, nominal_body)
        @message.deliver(:sms_gateway=>@gateway)
      end
    end # with single addresses

    describe 'with multiple addresses' do
      
      before(:each) do
        @members = members_w_contacts(2)
        @message.stub(:members).and_return(@members)   # NB: See above
        @message.stub(:sent_messages).and_return((0..@members.size-1).map{|n| SentMessage.new})
        @gateway = MockClickatellGateway.new(nil,@members)
      end
      
      it "Sends an email" do
        select_media(:email=>true)
        Notifier.should_receive(:send_generic).with(nominal_email_array, @message.body, true)
        @message.deliver
      end

      it "Sends an SMS" do
        select_media(:sms=>true)
        
        @gateway.should_receive(:deliver).with(nominal_phone_number_string, nominal_body).
          and_return('ID: AAAAAAAA') # return is not used in this test but is needed
        @message.deliver(:sms_gateway=>@gateway)
      end
    end # with multiple addresses

    describe 'message id and status' do
      describe 'with single phone number' do
        before(:each) do
          select_media(:sms=>true)
          @members = members_w_contacts(1, false)
          @message.save
          @gateway = MockClickatellGateway.new(nil,@members)
        end
        
        it "inserts gateway_message_id into sent_message" do
          @message.deliver(:sms_gateway=>@gateway)
          @gtw_id = @message.reload.sent_messages.first.gateway_message_id
          @gtw_id.should_not be_nil
          @gateway.mock_response.should match(@gtw_id)
        end
        
        it "inserts pending status into sent_message" do
          @message.deliver(:sms_gateway=>@gateway)
          @message.sent_messages.first.status.should == MessagesHelper::MsgSentToGateway
        end
        
        it "inserts error status into sent_message" do
          @gateway.mock_response = @gateway.error_response
          @message.deliver(:sms_gateway=>@gateway)
          @sent_message = @message.sent_messages.first
          @sent_message.status.should == MessagesHelper::MsgError
          @sent_message.gateway_message_id.should == @gateway.error_response
        end
      end # with single phone number

      describe 'with multiple phone numbers' do
        before(:each) do
          select_media(:sms=>true)
          @members = members_w_contacts(2, false) # false = "Don't use stubs, use real objects"
          @message.save
          @gateway = MockClickatellGateway.new(nil,@members)
        end
        
        it "inserts gateway_message_id into sent_message" do
          # This checks that gateway_message ids are inserted into the sent_message records when
          # deliver is called. Those gateway_message_ids are identifiers that the gateway
          # uses to update status later. So we need to be sure that the sent_message record
          # belonging to a given member gets the ID attached that corresponds to the same
          # phone number. I.e. if we get "ID: Abciciiix To: 2348087775555" from the gateway,
          # then the sent_message for the person with phone number 2348087775555 has to get
          # gateway_message_id 'Abciciiix'
          @message.deliver(:sms_gateway=>@gateway)
          @message.sent_messages.each do |sent_message|
            gtw_id = sent_message.gateway_message_id  
            gtw_id.should_not be_nil
            phone = sent_message.member.primary_contact.phone_1.gsub("+",'')
            @gateway.mock_response.should match("ID: #{gtw_id}\s+To: #{phone}")
          end
        end
        
        it "inserts pending status into sent_message" do
          @message.deliver(:sms_gateway=>@gateway)
          @message.sent_messages.first.status.should == MessagesHelper::MsgSentToGateway
        end
#        
#        it "inserts error status into sent_message" do
#          @gateway.mock_response = @gateway.error_response
#          @message.deliver(:sms_gateway=>@gateway)
#          @sent_message = @message.sent_messages.first
#          @sent_message.status.should == MessagesHelper::MsgError
#          @sent_message.gateway_message_id.should == @gateway.error_response
#        end

      end # with multiple phone numbers
    end # message id and status

  end # deliver

end
