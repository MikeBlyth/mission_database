require "spec_helper"
require 'sim_test_helper'
include SimTestHelper
include NotifierHelper

describe Notifier do
  describe "travel_mod" do
    let(:mail) { Notifier.travel_mod('test@example.com') }
    let(:trav_member) {Factory(:member)}
    let(:sixpm) {Time.new(0,1,1,18,0,0)}    

    it "renders the headers" do
      mail.subject.should eq("Travel schedule updates")
      mail.to.should eq(["test@example.com"])
      mail.from.should eq(["database@sim-nigeria.org"])
    end

    it "renders the body" do
      mail.body.encoded.should match("No changes found during last reporting period.")
    end

    it "makes deliverable mail" do
      mail.deliver
      ActionMailer::Base.deliveries.should_not be_empty
    end
    
    it "reports a changed travel record" do
      travel = Factory(:travel, :member=>trav_member, :date=>Date.today, :arrival=>false, :time=>Time.now, 
          :with_spouse=>true, :with_children=>true,
          :other_travelers=>'Grandparents')
      mail.body.should match(travel.member.name)      
      mail.deliver
    end
  end

  describe "send_test" do
    let(:mail) { Notifier.send_test('test@example.com', 'message') }

    it "renders the headers" do
      mail.subject.should =~ /test/i
      mail.to.should eq(["test@example.com"])
      mail.from.should eq(["database@sim-nigeria.org"])
    end

    it "renders the body" do
      mail.body.encoded.should =~ /test/i
      mail.body.encoded.should =~ /message/i
    end
  end

  describe 'send_family_summary' do
    before(:each) do 
      @family = factory_family_full(:couple=>false, :child=>false)
      @head = @family.head.reload
    end
    
    it 'creates a summary for a family' do
      message = Notifier.send_family_summary(@family)
      message.to_s.should match summary_header[0..20]
    end
 
    # The _contents_ of the summary are tested without having to invoke mailer
    it 'includes all specified information' do
      @head.personnel_data.reload.update_attributes(:est_end_of_service=> Date.today+5.years)
      contacts = @head.primary_contact
      contacts.update_attributes(
          :phone_1 => '0805=999=9999'.phone_format,
          :phone_2 => '0804-888-8999'.phone_format,
          :email_2 => 'me2@example.com',
          :photos => 'photo_site',
          :blog => 'blog',
          :other_website => 'other site',
          :facebook => 'fb'
          )
      summary = family_summary_content(@family)
      summary.should_not be_nil
#puts summary
      m = @head
      c = contacts
      h = @head.health_data
      p = @head.personnel_data
      t = @head.most_recent_term      
      required_fields = [
         m[:last_name], m[:first_name], m[:residence_location], m[:ministry], m[:status],
         m[:work_location], m[:country_name], m[:ministry_comment], m[:education],
         m[:birth_date],
         h[:bloodtype],
         p[:education], p[:date_active], p[:est_end_of_service],
         t[:start_date], t[:end_date],
         c[:phone_1], c[:phone_2], c[:email_1],  c[:email_2], c[:blog], c[:photos],
         c[:other_website], c[:facebook],
         ]
      required_fields.each {|field| summary.should match field.to_s}
    end            

    it 'handles member with no contact or field_term record' do
      Contact.delete_all
      FieldTerm.delete_all
      summary = family_summary_content(@family)
      summary.should_not be_nil
      missing = family_missing_info(@family).join("\n")
      missing.should match("primary phone")
      missing.should match("primary email")
      missing.should match("estimated end of current term")
      summary.should match(MISSING_CONTACT) 
      missing_flag = MISSING.gsub("*", "\\*")
        # This is ugly but since MISSING may have "*" inside it, must escape first to "\\*"
        # It just means, for example, should have "Start ... ***MISSING***" within the message
      summary.should match("Start.*#{missing_flag}") 
      summary.should match("End.*#{missing_flag}") 
      summary.should match("End.*#{missing_flag}") 
    end 
  
    it 'includes spouse data' do
      spouse = create_spouse(@head)
      contact = Factory(:contact, :member=>spouse, :phone_1 => 'spousephone')
      summary = family_summary_content(@family)
      summary.should match 'spousephone'    
      summary.should match spouse.first_name    
      summary.should match 'SPOUSE'    
      summary.should_not match 'CHILDREN'    
    end

    it 'includes child data' do
      child = Factory(:child, :family=>@family, :first_name=>'Sandy')
      summary = family_summary_content(@family)
      summary.should match 'CHILDREN'    
      summary.should match child.birth_date.to_s    
      summary.should match child.first_name    
      summary.should_not match 'SPOUSE'    
    end

  end
      
end
