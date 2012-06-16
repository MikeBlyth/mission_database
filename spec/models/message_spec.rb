require 'spec_helper'

class MockClickatellGateway < ClickatellGateway
  # Used for testing only (obviously, since it's in the testing library :-)
  # Set mock_response to literally what you want it to be or
  # Set members to an array of members (who must have primary_contacts defined)
  #   and the response will be generated based on the phone numbers of those members
  attr_accessor :mock_response, :members
  
  def initialize(response=nil, members=[])
    super()
    @mock_response = response
    @members = members
  end
  
  # Generate a Clickatell-style response like
  #    ID: ny4eiyiac4qfy7do4mgrydqyacoen652 To: 2348162522097
  #    ID: dxvtg2o9jhbqe4edifn026905st8mpz4 To: 2348162522102
  def generate_response
    if @members.size == 1
      "ID: #{rand(36**32).to_s(36)}"  # Phone number is not given when it's the only one
    else
      @members.map{|m| 
        "ID: #{rand(36**32).to_s(36)} To: #{m.primary_contact.phone_1.gsub("+",'')}"}.join("\n")
    end
  end
  
  def generate_error_response
    "ERR: 105, INVALID DESTINATION ADDRESS"
  end

  def deliver(*)
puts "**** call_gateway, @mock_response=#{@mock_response || "nil"}, generate_response=#{generate_response}"
    return @mock_response || generate_response
  end  
end

def member_w_contact
  member = Factory.stub(:member)
  contact = Factory.stub(:contact)
  member.stub(:primary_contact).and_return(contact)
  return member
end    

def members_w_contacts(n=1)
  all = []
  n.times { all << member_w_contact}
  # Set up group selection so that the generated members are the ones returned for every case
  Group.stub(:members_in_multiple_groups).and_return(all)
  # Make it appear that all these members are in country
  Member.stub(:those_in_country).and_return(all)
  return all
end  

# some shortcuts
def select_media(params={})
  params.each {|medium, truefalse| @message.stub("send_#{medium}".to_sym).and_return(truefalse)}
end

def nominal_phone_number_string
  @members.map {|m| m.primary_contact.phone_1.gsub('+','')}.join(',')
end

def nominal_email_array
  @members.map {|m| m.primary_contact.email_1}
end

def nominal_body
  "#{@message.body} #{@message.timestamp}"
end

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
  #    @old_sent_message = SentMessage
  #    silence_warnings{ SentMessage = mock_model(SentMessage)}
      @members = members_w_contacts(1)
      @message = Factory.build(:message, :created_at=>@created_at, :send_email=>true)
   #   @message.stub(:save).and_return(true)
    end
    after(:each) do
  #    silence_warnings{ SentMessage = @old_sent_message }
    end
    
    it 'excludes members who are not on the field' do
      Member.stub(:those_in_country).and_return([@members[0]])
      @message.save.should be_true   
      @message.members.should == [@members[0]]
    end      

    it 'saves sent_message record for member' do
      @message.save
      @message.save.should be_true   
      @message.members.should == @members
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
        @gateway = MockClickatellGateway.new(nil,@members)
      end
      
      it "Sends an email" do
        select_media(:email=>true)
        Notifier.should_receive(:send_generic).with(nominal_email_array, @message.body, true)
        @message.deliver
      end

      it "Sends an SMS" do
        select_media(:sms=>true)
        @gateway.should_receive(:deliver).with(nominal_phone_number_string, nominal_body)
        @message.deliver(:sms_gateway=>@gateway)
      end
    end # with multiple addresses

    describe 'message id and status' do
      
      it "inserts gateway_message_id into sent_message" do
        select_media(:sms=>true)
        @members = members_w_contacts(1)
        @gateway = MockClickatellGateway.new(nil,@members)
        @message.save
        @message.sent_messages.size.should == 1
        @message.members.should == @members
        @message.deliver(:sms_gateway=>@gateway)
        @gtw_id = @message.reload.sent_messages.first.gateway_message_id
puts "**** @gtw_id=#{@gtw_id}" 
        @gtw_id.should_not be_nil
        @gtw_id.size.should > 10
      end

    end # message id and status

  end # deliver

end
