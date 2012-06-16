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
    if @members.size = 1
      "ID: #{rand(36**32).to_s(36)}"  # Phone number is not given when it's the only one
    else
      @members.map{|m| 
        "ID: #{rand(36**32).to_s(36)} To: #{m.primary_contact.phone_1.gsub("+",'')}"}.join("\n")
    end
  end
  
  def generate_error_response
    "ERR: 105, INVALID DESTINATION ADDRESS"
  end

  def call_gateway
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

  describe 'delivers to gateways' do
    after(:each) do
      silence_warnings{ Notifier=@old_notifier }
    end
      
    before(:each) do
      # *** Mock the email generator, Notifier ***
        @email = mock('Email', :deliver=>nil)
        @old_notifier = Notifier
        silence_warnings{ Notifier = mock('Notifier', :send_generic => @email) }
      # Stuff needed for message
        @members = members_w_contacts(1)
      # *** Message ***
        @created_at = Time.new(2000,06,07,14,20)
        @message = Factory.build(:message, :created_at=>@created_at)
      # *** Gateway ****
#        @gw_msg_id = '74958a4f4c328c5bd4a988dfb5a0670c'
#        @gw_reply = "ID: #{@gw_msg_id}"
        @gateway = MockClickatellGateway.new(nil,@members)
      end
    
    it "Sends an email" do
      select_media(:email=>true)
      Notifier.should_receive(:send_generic).
        with([@members[0].primary_contact.email_1], @message.body)
      @message.deliver
    end

    it "Does not sends an email if it's not selected" do
      select_media(:email=>false)
      Notifier.should_not_receive(:send_generic).
        with([@members[0].primary_contact.email_1], @message.body)
      @message.deliver
    end

    it "Sends an SMS" do
      select_media(:sms=>true)
      @gateway.should_receive(:deliver)# .with(@contact.phone_1, "test message #{@message.timestamp}")
      @message.deliver(:sms_gateway=>@gateway)
    end

  end # deliver

end
