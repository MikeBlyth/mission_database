require 'spec_helper'
include SimTestHelper

def rebuild_message
    @params[:message] = "From: #{@params['from']}\r\n" + 
                         "To: #{@params['to']}\r\n" +
                         "Subject: #{@params['subject']}\r\n\r\n" + 
                         "#{@params['plain']}"
end

describe IncomingMailsController do
  before(:each) do
    @params = {
             'from' => 'member@example.com',
             'to' => 'database@sim-nigeria.org',
             'subject' => 'Test message',
             'plain' => '--content--',
             }
    rebuild_message
  end

  describe 'filters based on member status' do

    it 'accepts mail from SIM member (using email_1)' do
      @contact = Factory(:contact, :email_1 => @params['from'])  # have a contact record that matches from line
      post :create, @params
      response.status.should == 200
    end
    
    it 'accepts mail from SIM member (using email_2)' do
      @contact = Factory(:contact, :email_2 => @params['from'])  # have a contact record that matches from line
      post :create, @params
      response.status.should == 200
    end
    
    it 'accepts mail from SIM member (stubbed)' do
      Contact.stub(:find_by_email_1).and_return(true)  # have a contact record that matches from line
      post :create, @params
      response.status.should == 200
    end
    
    it 'rejects mail from strangers' do
      @contact = Factory(:contact, :email_1=> 'stranger@example.com')  # have a contact record that matches from line
      post :create, @params
      response.status.should == 403
      response.body.should =~ /refused/i
    end

  end # it filters ...


  describe 'processes' do
    before(:each) do
      Contact.stub(:find_by_email_1).and_return(true)  # have a contact record that matches from line
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
        @params['plain'] = e
        rebuild_message # needed only if the controller gets info from mail object made from params['message']
        post :create, @params
        response.status.should == 200
      end  
    end    

    it 'single command on first line' do
      @params['plain'] = 'Test with parameters list'
      rebuild_message # needed only if the controller gets info from mail object made from params['message']
      post :create, @params
      response.status.should == 200
      lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(1)
#puts ActionMailer::Base.deliveries.first.to_s
    end

    it 'commands on two lines' do
      @params['plain'] = "Test for line 1\nTest for line 2"
      rebuild_message # needed only if the controller gets info from mail object made from params['message']
      lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(2)
      response.status.should == 200
      ActionMailer::Base.deliveries.last.to_s.should =~ /line 2/
      ActionMailer::Base.deliveries.last.to_s.should match("To: #{@params['from']}")
#puts ActionMailer::Base.deliveries.last.to_s
    end

  end # processes commands

  describe 'handles these commands:' do
    before(:each) do
      Contact.stub(:find_by_email_1).and_return(true)  # have a contact record that matches from line
      contact_type = Factory(:contact_type)
    end      
    
    it "info" do
      member = create_couple
      contact = Factory :contact, :member => member
      contact_spouse = Factory :contact, :member => member.spouse, :email_1 => 'spouse@example.com'
      other = Factory :family, :last_name => 'Finklestein'
      @params['plain'] = "info #{member.last_name}"
      post :create, @params
      ActionMailer::Base.deliveries.last.to_s.should =~ Regexp.new(member.last_name)
      ActionMailer::Base.deliveries.last.to_s.should =~ Regexp.new(member.primary_contact.email_1)
      ActionMailer::Base.deliveries.last.to_s.should =~ Regexp.new(member.primary_contact.phone_1)
    end    
  end # handles these commands
   

end
