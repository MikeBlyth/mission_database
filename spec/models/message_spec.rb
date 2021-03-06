require 'spec_helper'
require '~/simjos/spec/support/mock_clickatell_gateway'
require '~/simjos/spec/support/messages_test_helper'
include MessagesTestHelper
include SimTestHelper

describe Message do
    before(:each) do
      @message = Message.new(:body=>'test message', :sms_only => '#'*50)
      @message.stub(:created_at).and_return(Time.now)
    end

  describe 'initialization and validation' do
    
    it 'sets defaults [NB: adjust tests if you change defaults!]' do
      settings_with_default = [:confirm_time_limit, :retries, :retry_interval, :expiration, 
                               :response_time_limit, :importance]
      m = Message.new
      settings_with_default.each do |setting| 
         m.send(setting).should == Settings.messages[setting]
      end
      # The names or actual settings might get changed here, so this test may be modified   
    end     
  
#    it 'catches SMS messages that are too short' do
#      @message.send_sms = true
#      @message.sms_only = 'short'
#      @message.save
#      @message.errors[:sms_only].should_not be_blank
#    end
      
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
      @members = members_w_contacts(2) # creates two members and arranges for them to appear as the targets for this message
                                       # See in messages_test_helper.rb
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
        @message = Factory.build(:message, :created_at=>@created_at, :subject=>'Subject line',
            :sms_only => "#"*40)
    end

    describe 'with single addresses' do
      
      before(:each) do
        # Note that in these tests we simply *insert* the members during the test setup,
        # since we have already tested that Message will do that properly. Otherwise we
        # will have to "save" the message first, to trigger the creation of the sent_message
        # records that tie the message to the members.
        # Note that you can't access sent_message records unless they *are* created.
        @resp_time_limit = 5
        @members = members_w_contacts(1, false)
#        @message.stub(:subject).and_return('Subject line')
#        @message.stub(:id).and_return(21)
        @message.subject = 'Subject line'
        @message.response_time_limit = @resp_time_limit
        @gateway = MockClickatellGateway.new(nil,@members)
      end
      
      it "Sends an email only" do
        select_media(:email=>true)
        @message.response_time_limit.should == @resp_time_limit
        Notifier.should_receive(:send_group_message).
          with(:recipients => [@members[0].primary_contact.email_1], :content => @message.body, 
          :subject => @message.subject, :id => anything(), 
          :response_time_limit => @resp_time_limit, #@message.response_time_limit,
          :bcc => true,
          :following_up => nil)
        @gateway.should_not_receive(:deliver)
        @message.deliver
      end

      it "Sends an SMS" do
        select_media(:sms=>true)
        @message.sms_only = "#"*50
        Notifier.should_not_receive(:send_group_message)
        @gateway.should_receive(:deliver).with(nominal_phone_number_string, Regexp.new(@message.sms_only))
        @message.deliver(:sms_gateway=>@gateway)
      end
      
      it "Inserts response tag" do
        select_media(:sms=>true)
        @message.response_time_limit = 15
        @message.deliver(:sms_gateway=>@gateway)
        @message.sms_only.should match Regexp.new("!"+@message.id.to_s)
      end
    end # with single addresses

    describe 'with multiple addresses' do
      
      before(:each) do
        @members = members_w_contacts(2, false)
        @gateway = MockClickatellGateway.new(nil,@members)
      end
      
      it "Sends an email" do
        select_media(:email=>true)
        
        Notifier.should_receive(:send_group_message) do |params|
          params[:recipients].should =~ nominal_email_array 
          params[:content].should == @message.body
          params[:subject].should == @message.subject
          params[:response_time_limit].should == @message.response_time_limit
          params[:bcc].should == true
        end.and_return(mock('Message', :deliver => true))
        @message.deliver
      end

      it "Sends an SMS" do
        select_media(:sms=>true)
        @message.sms_only = "#"*50
        @gateway.stub(:deliver).and_return('ID: AAAAAAAA') # return is not used in this test but is needed
        @gateway.should_receive(:deliver) do |phone_numbers, body|
          phone_numbers.split(',').should =~ @members.map {|m| m.primary_phone}
          body.should =~ Regexp.new(@message.sms_only)
        end.and_return('')
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
          #NB: The message w contact list is already formed by all the before(:all) blocks. In order to test a message
          #    going to someone without a phone number, we need to recreate the message after deleting the phone numbers.
          @members[1].primary_contact.update_attributes(:phone_1 => nil, :phone_2 => nil)
          @message.save
          @message.deliver(:sms_gateway=>@gateway)
          @gateway.numbers.should == [@members[0].primary_contact.phone_1.sub('+', '')] # i.e., should only include 1 number
        end          

        it "does not include duplicate phone numbers" do
          #NB: See above
          @members[1].primary_contact.update_attributes(:phone_1 => @members[0].primary_contact.phone_1, :phone_2 => nil)
          @members[1].primary_contact.phone_1.should == @members[0].primary_contact.phone_1
          @message.create_sent_messages
          @message.deliver(:sms_gateway=>@gateway)
          @gateway.numbers.should == [@members[0].primary_contact.phone_1.sub('+', '')] # i.e., should only include 1 number
        end
        
        it 'does not create sent_message record for SMS person without phone' do
          @members[1].primary_contact.update_attributes(:phone_1 => nil, :phone_2 => nil)
          @message.stub(:send_sms => true)
          @message.stub(:send_email => false)
          @message.create_sent_messages
          @message.members.should == [@members[0]]
        end
                            
        it '*does* create sent_message record for emailing person without phone' do
          @members[1].primary_contact.update_attributes(:phone_1 => nil, :phone_2 => nil)
          @message.stub(:send_sms => false)
          @message.stub(:send_email => true)
          @message.create_sent_messages
          @message.members.should == [@members[0], @members[1]]
        end
                            
        it 'does not create sent_message record for email person without address' do
          @members[1].primary_contact.update_attributes(:email_1 => nil, :email_2 => nil)
          @message.stub(:send_sms => false)
          @message.stub(:send_email => true)
          @message.create_sent_messages
          @message.members.should == [@members[0]]
        end
                            
        it 'does not create sent_message record someone w no phone or email' do
          @members[1].primary_contact.update_attributes(:email_1 => nil, :email_2 => nil, :phone_1=>nil, :phone_2=>nil)
          @message.stub(:send_sms => true)
          @message.stub(:send_email => true)
          @message.create_sent_messages
          @message.members.should == [@members[0]]
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

  describe 'lists members not yet having responded' do
    before(:each) do
      @message = Factory(:message, :send_email=>true)
      @fast_responder = build_member_without_family
      @slow_responder = build_member_without_family
      @message.members << [@fast_responder, @slow_responder]
      @sent_messages = @message.sent_messages
    end

    it 'when one has responded' do
      @fast_responder.sent_messages.first.update_attributes(:msg_status => MessagesHelper::MsgResponseReceived)
      @message.members_not_responding.should == [@slow_responder]
    end
    
    it 'when both have responded' do
      SentMessage.update_all(:msg_status => MessagesHelper::MsgResponseReceived)
      @message.members_not_responding.should =~ []
    end
    
    it 'when neither have responded' do
      @message.members_not_responding.should =~ [@fast_responder, @slow_responder]
    end
    
  end   # lists members not yet having responded






end
