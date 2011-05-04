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
    
    it 'variety of "command" lines without crashing' do
      examples = [ "",
                   "command",
                   "command and params",
                   "two\nlines",
                   "two\n\nwith blank between",
                   "command\tseparated by tab and not space",
                   ]
      examples.each do |e|
        @mail.body = e
        Incoming.receive(@mail).should == true
      end  
    end    

    it 'single command on first line' do
      @mail.body = 'Test with parameters list'
      Incoming.receive(@mail).should == true
      ActionMailer::Base.deliveries.should_not be_empty
#puts ActionMailer::Base.deliveries.first.to_s
    end

    it 'commands on two lines' do
      @mail.body = "Test for line 1\nTest for line 2"
      Incoming.receive(@mail).should == true
      ActionMailer::Base.deliveries.length.should == 2
      ActionMailer::Base.deliveries.last.to_s.should =~ /line 2/
#puts ActionMailer::Base.deliveries.last.to_s
    end

  end # processes commadns
end
