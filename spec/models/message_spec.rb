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
    
    it 'sets defaults [NB: adjust tests if you change defaults!]' do
      m = Message.new
      m.retries.should_not be_nil
      m.confirm_time_limit.should_not be_nil
      m.retry_interval.should_not be_nil
      m.expiration.should_not be_nil
      m.response_time_limit.should be_nil
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
        silence_warnings{ Notifier = mock('Notifier', :send_group_message => @email) }
        @old_applog = AppLog
        silence_warnings { AppLog = mock('AppLog').as_null_object }
      # *** Message ***
        @created_at = Time.new(2000,06,07,14,20)
        @message = Factory.build(:message, :created_at=>@created_at, :subject=>'Subject line')
    end

    describe 'with single addresses' do
      
      before(:each) do
        # Note that in these tests we simply *insert* the members during the test setup,
        # since we have already tested that Message will do that properly. Otherwise we
        # will have to "save" the message first, to trigger the creation of the sent_message
        # records that tie the message to the members.
        # Note that you can't access sent_message records unless they *are* created.
        @members = members_w_contacts(1, false)
        @message.stub(:subject).and_return('Subject line')
        @message.stub(:id).and_return(21)
        @gateway = MockClickatellGateway.new(nil,@members)
      end
      
      it "Sends an email only" do
        select_media(:email=>true)
        Notifier.should_receive(:send_group_message).
          with(:recipients => [@members[0].primary_contact.email_1], :content => @message.body, 
          :subject => @message.subject, :id => anything(), 
          :response_time_limit => @message.response_time_limit,
          :bcc => true)
        @gateway.should_not_receive(:deliver)
        @message.deliver
      end

      it "Sends an SMS" do
        select_media(:sms=>true)
        Notifier.should_not_receive(:send_group_message)
        @gateway.should_receive(:deliver).with(nominal_phone_number_string, nominal_body)
        @message.deliver(:sms_gateway=>@gateway)
      end
      
      it "Inserts response tag" do
        select_media(:sms=>true)
        @message.response_time_limit = 15
        @message.deliver(:sms_gateway=>@gateway)
        @message.body.should match Regexp.new("!"+@message.id.to_s)
      end
    end # with single addresses

    describe 'with multiple addresses' do
      
      before(:each) do
        @members = members_w_contacts(2, false)
        @gateway = MockClickatellGateway.new(nil,@members)
      end
      
      it "Sends an email" do
        select_media(:email=>true)
        Notifier.should_receive(:send_group_message).with(:recipients => nominal_email_array, 
          :content => @message.body, 
          :subject => @message.subject, 
          :id => anything(), 
          :response_time_limit => @message.response_time_limit,
          :bcc => true)
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
          @message.sent_messages.first.msg_status.should == MessagesHelper::MsgSentToGateway
        end
        
        it "inserts error status into sent_message" do
          @gateway.mock_response = @gateway.error_response
          @message.deliver(:sms_gateway=>@gateway)
          @sent_message = @message.sent_messages.first
          @sent_message.msg_status.should == MessagesHelper::MsgError
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
          @message.sent_messages.first.msg_status.should == MessagesHelper::MsgSentToGateway
        end
        
        it "inserts error status into sent_message" do
          @gateway.mock_response = @gateway.error_response
          @message.deliver(:sms_gateway=>@gateway)
          @sent_message = @message.sent_messages.first
          @sent_message.msg_status.should == MessagesHelper::MsgError
        end
    
        it "does not include empty phone numbers" do
          @members[1].primary_contact.update_attributes(:phone_1 => nil, :phone_2 => nil)
          @message.deliver(:sms_gateway=>@gateway)
          @gateway.numbers.should == [@members[0].primary_contact.phone_1.sub('+', '')]
        end          

        it "does not include empty phone numbers" do
          @members[1].primary_contact.update_attributes(:phone_1 => '', :phone_2 => '')
          @message.deliver(:sms_gateway=>@gateway)
          @gateway.numbers.should == [@members[0].primary_contact.phone_1.sub('+', '')]
        end          

      end # with multiple phone numbers
    end # message id and status

  end # delivers to gateways
  
  describe 'gives status reports:' do
    before(:each) do
      @sent_messages = (0..5).map {|i| mock_model(SentMessage, :id=>i, 
          :msg_status=>MessagesHelper::MsgSentToGateway).as_null_object}
      @sent_messages.each do |m| 
        m.stub(:member).and_return(mock_model(Member, :shorter_name=>"Name #{m.id+1}"))
      end
      @message = Factory.stub(:message)
      @message.stub(:sent_messages).and_return @sent_messages
    end
    
    it '(check test setup)' do
      @message.sent_messages.size.should == @sent_messages.size
      @message.sent_messages.first.msg_status.should == @sent_messages.first.msg_status
      @message.sent_messages.first.member.shorter_name.should == 'Name 1'
    end
    
    it 'reports "pending"' do
      @message.current_status.should == {:pending=>6, :delivered=>0, :replied=>0, :errors=>0,
        :pending_names=>'Name 1, Name 2, Name 3, Name 4, Name 5, Name 6',
        :errors_names => "",
        :delivered_names=>"",
        :replied_names=>""
        }
    end
    it 'reports "sent to gateway" as "pending"' do
      @sent_messages[0].stub(:msg_status).and_return(MessagesHelper::MsgPending)
      @message.current_status.should == {:pending=>6, :delivered=>0, :replied=>0, :errors=>0,
        :pending_names=>'Name 1, Name 2, Name 3, Name 4, Name 5, Name 6',
        :errors_names => "",
        :delivered_names=>"",
        :replied_names=>""
        }
    end
    it 'reports "delivered"' do
      @sent_messages[0].stub(:msg_status).and_return(MessagesHelper::MsgDelivered)
      @message.current_status.should == {:pending=>5, :delivered=>1, :replied=>0, :errors=>0,
        :pending_names=>'Name 2, Name 3, Name 4, Name 5, Name 6',
        :errors_names => "",
        :delivered_names=>"Name 1",
        :replied_names=>""
        }
    end
    it 'reports "replied"' do
      @sent_messages[0].stub(:msg_status).and_return(MessagesHelper::MsgResponseReceived)
      @message.current_status.should == {:pending=>5, :delivered=>0, :replied=>1, :errors=>0,
        :pending_names=>'Name 2, Name 3, Name 4, Name 5, Name 6',
        :errors_names => "",
        :delivered_names=>"",
        :replied_names=>"Name 1"
        }
    end
    it 'reports "errors"' do
      @sent_messages[0].stub(:msg_status).and_return(MessagesHelper::MsgError)
      @sent_messages[1].stub(:msg_status).and_return(nil)
      @message.current_status.should == {:pending=>4, :delivered=>0, :replied=>0, :errors=>2,
        :pending_names=>'Name 3, Name 4, Name 5, Name 6',
        :errors_names => "Name 1, Name 2",
        :delivered_names=>"",
        :replied_names=>""
        }
    end
    
  end # reports status

  describe 'processes responses from recipients' do
    before(:each) do
      @member = mock_model(Member, :id=>100)
      @sent_messages = (0..2).map {|i| mock_model(SentMessage, :id=>i,
          :member_id => @member.id-1 + i, # so middle one gets the right member
          :msg_status=>MessagesHelper::MsgSentToGateway).as_null_object}
      @message.stub(:sent_messages).and_return(@sent_messages)
    end

    it 'marks sent_message with response status' do
      @resp_text = 'I got it'
      @sent_messages[1].should_receive(:update_attributes).
          with(:msg_status=>MessagesHelper::MsgResponseReceived,
          :confirmed_mode=>"email",
          :confirmation_message=>@resp_text, :confirmed_time => instance_of(Time))
      @sent_messages[0].should_not_receive(:update_attributes)
      @sent_messages[2].should_not_receive(:update_attributes)
      @message.process_response(:member => @member, :text => @resp_text, :mode => 'email')
    end
  end # processes responses from recipients

end
