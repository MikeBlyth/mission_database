require "spec_helper"

describe Incoming do
  it 'responds somehow' do
    mail = Factory.build :mail
    Incoming.receive(mail).should_not be_nil
  end

  describe 'filters based on member status' do

    it 'accepts mail from SIM member (using email_1)' do
      mail = Factory.build :mail
      @contact = Factory(:contact, :email_1 => mail.from.first)  # have a contact record that matches from line
      Incoming.receive(mail).should == true
    end
    
    it 'accepts mail from SIM member (using email_2)' do
      mail = Factory.build :mail
      @contact = Factory(:contact, :email_2 => mail.from.first)  # have a contact record that matches from line
      Incoming.receive(mail).should == true
    end
    
    it 'accepts mail from SIM member (stubbed)' do
      mail = Factory.build :mail
      Contact.stub(:find_by_email_1).and_return(true)  # have a contact record that matches from line
      Incoming.receive(mail).should == true
    end
    
    it 'rejects mail from strangers' do
      mail = Factory.build :mail
      @contact = Factory(:contact, :email_1=> 'stranger@example.com')  # have a contact record that matches from line
      Incoming.receive(mail).should == false
    end

  end # it filters ...

  describe 'processes' do
    before(:each) do
      Contact.stub(:find_by_email_1).and_return(true)  # have a contact record that matches from line
      @mail = Factory.build :mail
    end      
    
    it 'single command on first line' do
      @mail.body = 'XTest with parameters list'
      xtest = mock('xtest')
      xtest.should_receive
      Incoming.receive(@mail).should == true
    end

  end # processes commadns
end
