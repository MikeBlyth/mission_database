require 'spec_helper'
include SimTestHelper
include ApplicationHelper
include IncomingMailsHelper
  
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
    ActionMailer::Base.deliveries.clear  # clear incoming mail queue
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
      controller.stub(:from_member).and_return(Member.new)  # have a contact record that matches from line
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
      controller.stub(:from_member).and_return(Member.new)   # have a contact record that matches from line
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
      controller.stub(:from_member).and_return(Member.new)   # have a contact record that matches from line
      contact_type = Factory(:contact_type)
    end      
    
    describe 'info sends contact info' do

      it 'sends the email' do
        @params['plain'] = "info stranger"
        lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(1)
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
      end  

      it "gives error message if name not found" do
        @params['plain'] = "info stranger"
        post :create, @params
        mail = ActionMailer::Base.deliveries.last.to_s
        mail.should =~ /no.*found/i      
      end

      it "sends basic info if contact record not found" do
        member = Factory(:member, :last_name=>'Jehu')
        @params['plain'] = "info Jehu"
        post :create, @params
        mail = ActionMailer::Base.deliveries.last.to_s
        mail.should =~ /Jehu/
        mail.should =~ /no contact/i
      end

      it "includes all relevant info for couple" do
        member = create_couple
        residence_location = Factory(:location, :description=>'Rayfield')
        work_location = Factory(:location, :description=>'Spring of Life')
        member.update_attributes(:birth_date => Date.new(1980,6,15),
#*                     :residence_location=>residence_location,
                     :work_location=>work_location,
                     :temporary_location => 'Miango Resort Hotel',
                     :temporary_location_from_date => Date.today - 10.days,
                     :temporary_location_until_date => Date.today + 2.days,
                     )
                     
        contact = Factory :contact, :member => member
        contact_spouse = Factory :contact, :member => member.spouse, 
                    :email_1 => 'spouse@example.com',
                    :email_2 => 'josette@gmail.com',
                    :phone_2 => '0707-777-7777',
                    :skype => 'Josette', :skype_private => false,
                    :blog => 'http://josette.blogspot.com',
                    :photos => 'http://myphotos.photos.com'
        other = Factory :family, :last_name => 'Finklestein'
        @params['plain'] = "info #{member.last_name}"
        post :create, @params
        mail = ActionMailer::Base.deliveries.last.to_s
        required_contents = [member.residence_location, member.work_location, member.temporary_location,
             member.last_name, member.first_name, member.primary_contact.email_1, member.birth_date.to_s(:short),
             contact_spouse.email_1, contact_spouse.email_2, 
             format_phone(contact_spouse.phone_1), format_phone(contact_spouse.phone_2),
             contact_spouse.skype,  contact_spouse.blog, contact_spouse.photos,
             ]
        required_contents.each do |target|
          mail.should =~ Regexp.new(target.to_s)
        end
        mail.should_not match 'Finklestein'
      end    # example

      describe 'info marked as private' do

        it 'is hidden to 3rd party' do
     #     requestor = Factory(:family).head  # This is the person mailing in the request
     #     requestor_contact = Factory(:contact, :member=>requestor) # must have contact info in DB or will not recieve reply
          member = Factory(:member)     # This is the person for whom info is being requested
          contact = Factory(:contact, :member => member, 
                      :email_1 => 'member2@example.com',
                      :email_2 => 'secondary@gmail.com',
                      :phone_2 => '0707-777-7777',
                      :phone_1 => '0807-777-7777',
                      :skype => 'MySkype',
                      :skype_private => true, # phone, email and skype are all marked as private
                      :email_private => true,
                      :phone_private => true,
                      :blog => 'http://josette.blogspot.com',
                      :photos => 'http://myphotos.photos.com')
     #     @params['from'] = requestor_contact.email_1 # set up @params with requestor email and the request itself
          @params['plain'] = "info #{member.last_name}"
          post :create, @params
          mail = ActionMailer::Base.deliveries.last.to_s
          # None of these should be found as they're all marked private
          [:email_1, :email_2, :skype].each do |field|
            mail.should_not match(contact[field])
          end 
          [:phone_1, :phone_2].each do |field|
            mail.should_not match Regexp.new("#{contact[field].phone_format}.*private")
          end
          mail.should match(contact[:photos])          
        end # hides contact info marked as private     
      
        it 'is shown when requested by same member' do
          member = Factory(:member)
          controller.stub(:from_member).and_return(member)   # indicate that mail originates from same member as being requested
          contact = Factory(:contact, :member => member, 
                      :email_2 => 'secondary@gmail.com',
                      :phone_2 => '0707-777-7777'.phone_format,
                      :phone_1 => '0807-777-7777'.phone_format,
                      :skype => 'MySkype',
                      :skype_private => true,
                      :email_private => true,
                      :phone_private => true,
                      :blog => 'http://josette.blogspot.com',
                      :photos => 'http://myphotos.photos.com')
          @params['plain'] = "info #{member.last_name}"
          post :create, @params
          mail = ActionMailer::Base.deliveries.last.to_s
          [:email_1, :email_2, :skype].each do |field|
            mail.should =~ Regexp.new("#{contact[field]}.*private")
          end
          [:phone_1, :phone_2].each do |field|
            mail.should =~ Regexp.new("#{contact[field].phone_format}.*private")
          end
          mail.should match(contact[:photos])          
        end # is shown when requested by same member 

      end # info marked as private
      
    end # info
    
    describe 'directory' do
      before(:each) {@params['plain'] = "directory"}
      
      it 'sends the email' do
        lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(1)
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
      end  

      it 'sends Where Is report as attachment' do
        post :create, @params
        mail = ActionMailer::Base.deliveries.last
        attachment = ActionMailer::Base.deliveries.last.attachments.first
        attachment.filename.should == Settings.reports.filename_prefix + 'directory.pdf'
      end
    end #directory
    
    describe 'travel' do
      before(:each) {@params['plain'] = "travel"}
      
      it 'sends the email' do
        post :create, @params
        ActionMailer::Base.deliveries.length.should == 1
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
      end  

      it 'sends travel schedule as attachment' do
        post :create, @params
        ActionMailer::Base.deliveries.length.should == 1
        mail = ActionMailer::Base.deliveries.last
        attachment = ActionMailer::Base.deliveries.last.attachments.first
        attachment.filename.should == Settings.reports.filename_prefix + 'travel_schedule.pdf'
      end
    end #directory
    
    describe 'birthday list' do
      before(:each) {@params['plain'] = "birthdays"}
      
      it 'sends birthday list as attachment' do
        post :create, @params
        ActionMailer::Base.deliveries.length.should == 1
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
        attachment = ActionMailer::Base.deliveries.last.attachments.first
        attachment.filename.should == Settings.reports.filename_prefix + 'birthdays.pdf'
      end
    end #birthdays
    
    describe 'help command' do
      before(:each) {@params['plain'] = "help"}
      
      it 'sends basic help info' do
        post :create, @params
        ActionMailer::Base.deliveries.length.should == 1
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
        mail = ActionMailer::Base.deliveries.last.to_s.gsub("\r", "")
        mail.should match 'Accessing the SIM Nigeria Database by Email'
      end
    end #help
    
  end # handles these commands
   

end
