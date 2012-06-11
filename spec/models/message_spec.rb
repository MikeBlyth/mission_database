require 'spec_helper'

describe Message do
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
    before(:each) do
      @message = Message.new(:body=>'test')
    end
    
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
      @message.to_groups = ["1", "4"]
      @message.save
      @message.to_groups.should == "1,4"
    end
            

  end # to_groups field

end
