require 'spec_helper'

describe Message do
  before(:each) do
    @message = Message.new(:body=>'test')
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
      @message.send_email = true
      @message.to_groups = ["1", "4"]
      @message.save
      @message.should be_valid
      @message.to_groups.should == "1,4"
    end

  end # to_groups field
            
  describe 'member selection:' do
    it 'excludes members who are not on the field' do
      @on_field = Factory.stub(:member)
      @off_field = Factory.stub(:member)
      Group.stub(:members_in_multiple_groups).and_return([@on_field, @off_field])
      Member.stub(:those_in_country).and_return([@on_field])
      @message.to_groups = '1'
      @message.send_messages    
      @message.members.should == [@on_field]
    end      
  end #member selection

end
