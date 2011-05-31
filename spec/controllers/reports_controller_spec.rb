require 'spec_helper'

describe ReportsController do
   # render_views
  include ApplicationHelper

#  reports = %w(bloodtypes birthdays birthday_calendar phone_email travel_schedule)
#  describe "authentication before controller access" do

#    describe "for non-signed-in users" do
#    
#      it 'does not allow access to reports' do
#        reports.each do |report|
#          puts "\tChecking #{report}"
#          get report
#          response.should redirect_to(signin_path) 
#        end  
#      end

#    end #  "for non-signed-in users" 
#  end # "authentication before controller access"
#  
  describe "calendar reports" do
  
    it "merges data hashes correctly" do
      birthdays = {1 => {:text => "BD: John\n", :font_size=>12}, 4 => {:text => "BD: Mary\nBD: Joan\n", :align=> :center} }
      travels = {1 => {:text => "AR: Arin\n", :font_size=>14, :align=>:center}, 2 => {:text=>"DP: Jack\n", :font_size=>8},
                 4 => {:text => "DP: Oren\n", :align=>:right} }
      ReportsController.send(:public, *ReportsController.private_instance_methods)
      merged = controller.merge_calendar_data( [birthdays, travels] )           
      merged[1][:text].should == birthdays[1][:text] + travels[1][:text]
      merged[1][:font_size].should == birthdays[1][:font_size]
      merged[1][:align].should == travels[1][:align]
      #
      merged[2][:text].should == travels[2][:text]
      merged[2][:font_size].should == travels[2][:font_size]
      #
      merged[4][:text].should == birthdays[4][:text] + travels[4][:text]
      merged[4][:font_size].should == nil
      merged[4][:align].should == birthdays[4][:align]
    end
    
  end # describe "calendar reports"  

  describe "smart_join" do  # This isn't really in reports_controller, but in application_helper.
    it "works" do
      smart_join([' a ', '', nil, 25, "\ncat\t\n"]).should == "a, 25, cat"
      smart_join([' a ', '', nil, 25, "\ncat\t\n"], "::").should == "a::25::cat"
    end
  end  
    
  describe "sends Where Is report by email" do
    before(:each) do
      @user = Factory(:user, :admin=>true)  #   Sign in as admin so the controllers will work!
      test_sign_in(@user)
      @params = {:mail_to => "test@example.com", :format=>'pdf'}
      @member = Factory(:family).head
    end
    
    it 'sends the email' do
      lambda{get :whereis, @params}.should change(ActionMailer::Base.deliveries, :length).by(1)
    end  

    it 'email contains attachment' do
      get :whereis, @params
      mail = ActionMailer::Base.deliveries.last
      mail.attachments.should_not be_empty
    end  

  end # sends Where Is report by email

  # Field Term report: tested in reports.feature
  
  describe 'contact updates' do
    before(:each) do
      test_sign_in_fast
    end      
    
    
    it 'are reviewed' do
      member = Factory(:member_without_family)
      contact = Factory(:contact, :member=>member)
      get :contact_updates

      assigns[:contacts].should == [contact] 
      response.should render_template('contact_updates')
    end

    it 'are emailed' do
      member = Factory(:member_without_family)
      contact = Factory(:contact, :member=>member)
      lambda {post :send_contact_updates}.
        should change(ActionMailer::Base.deliveries, :length).by(1)  
    end
    
    it 'are shown in the email' do
      member = Factory(:member_without_family)
      contact = Factory(:contact, :member=>member)
      post :send_contact_updates
      mail = ActionMailer::Base.deliveries.last
      mail.to_s.should =~ Regexp.new(member.last_name)
      mail.to_s.should =~ Regexp.new(contact.email_1)
    end

  end # contact updates

end # describe ReportsController

