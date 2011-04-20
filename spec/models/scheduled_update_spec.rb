require 'spec_helper'

describe ScheduledUpdate do

  describe 'validation' do
    
    before(:each) do
      @s = Factory.build(:scheduled_update)
    end

    it 'is valid with factory defaults' do
      @s.should be_valid
    end

    it 'is not valid without a date' do
      @s.action_date = nil
      @s.should_not be_valid
    end 
  
    it 'is not valid with a past date' do
      @s.action_date = Date.yesterday
      @s.should_not be_valid
    end 
  
    it 'is valid with no member or family id' do
      @s.member_id = nil
      @s.family_id = nil
      @s.should be_valid
    end
    
    it 'is not valid if member does not exist' do
      @s.member_id = 999999
      @s.should_not be_valid
    end

    it 'is not valid if family does not exist' do
      @s.family_id = 999999
      @s.should_not be_valid
    end

  end # describe validation
  
  describe 'setup' do

    it 'sets status of new record to "pending"' do
      s = Factory(:scheduled_update)
      s.status.should == 'pending'
    end

  end

end

describe ScheduledUpdateMemberStatus do

  describe 'validation' do
    
    before(:each) do
      @status = Factory.build(:status)
      @s = Factory.build(:scheduled_update_member_status)
    end
    
    it 'is valid when new_value is existing status code' do
      @status.save
      @s.new_value = @status.code
      @s.should be_valid
    end
  
    it 'is not valid when new_value is not an existing status code' do
      @s.should_not be_valid
      @s.errors[:new_value].should_not be_nil
    end
  
  end # validation

  describe 'setup' do
    before(:each) do
      @status = Factory(:status)
    end

    it 'sets old_value of new record to member status' do
      member = Factory.stub(:member, :status=>@status)
      s = Factory(:scheduled_update_member_status, :member=>member, :new_value=>@status.code)
      s.old_value.should == member.status.code
    end

    it 'sets old_value of new record to "nil" if no member status' do
      member = Factory.stub(:member, :status=>nil)
      s = Factory(:scheduled_update_member_status, :member=>member, :new_value=>@status.code)
      s.old_value.should == 'nil'
    end

  end # describe setup
  
  describe 'execute' do
    before(:each) do
      @status = Factory(:status)
      @member = Factory(:member, :status=>@status)
      @new_status = Factory(:status)
      @s = Factory(:scheduled_update_member_status, :member=>@member, 
          :new_value=>@new_status.code, :status=>'pending')
    end  
    
    it 'updates member status if everything is valid' do
      @s.execute
      @s.reload.status.should == 'finished'
      @member.reload.status.should == @new_status
    end
    
    it 'ignores update unless status is "pending"' do
      @s.status = 'other'
      @s.execute
      @s.status.should == 'other'
    end
    
    it 'aborts with error if member is not found' do
      @member.delete
      @s.reload
      @s.member.should be_nil
      @s.execute
      @s.reload.status.should =~ /error/
    end
    
    it 'aborts with error if status code is not found' do
      @s.status.should == 'pending'
      @s.new_value = 'bad code'
      @s.execute
      @s.reload.status.should =~ /error/
    end
    
  end

end

