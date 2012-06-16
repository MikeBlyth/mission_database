require "spec_helper"
require 'sim_test_helper'
include SimTestHelper
include NotifierHelper

describe Notifier do
    let(:sixpm) {Time.new(2010,1,1,18,0,0)}    
    let(:twopm) {Time.new(2010,1,1,14,0,0)}    
#  ## NB! Using a before(:all) which can cause dependency problems if anything defined in this
#  ##   block is changed directly or indirectly by examples. ContactType is defined so that
#  ##   contact records have a valid type (without having to define it each time) and there
#  ##   is no reason to change any ContactType records in this test suite. 
#  before(:all) do 
#    Factory :contact_type
#  end

  # TODO: this partly duplicates tests found in admin controller
  # Need to rationalize division of mailer tests between controllers and mailer.

  describe "send_generic" do
    
    it 'normally sets To: field' do
      mail = Notifier.send_generic("test@example.com",'body')
      mail.to.should == ["test@example.com"]
      mail.bcc.should be_empty
    end
    it 'sets Bcc: field and not To: if bcc is selected' do
      mail = Notifier.send_generic("test@example.com",'body', true)
      mail.bcc.should == ["test@example.com"]
      mail.to.should be_empty
    end
  end

  describe "travel_updates" do
    let(:mail) { Notifier.travel_updates('test@example.com', (@travel ? [@travel] : nil)) }
    let(:trav_member) {Factory.stub(:member_without_family)}

    it "renders the headers" do
      mail.subject.should eq("Travel schedule updates")
      mail.to.should eq(["test@example.com"])
      mail.from.should eq(["database@sim-nigeria.org"])
    end

    it "renders the body" do
      mail.body.encoded.should match("No changes found during last reporting period.")
      mail.body.encoded.should match "latest updates"
    end

    it "makes deliverable mail" do
      mail.deliver
      ActionMailer::Base.deliveries.should_not be_empty
    end
    
    it "reports a changed travel record" do
      @travel = Factory.stub(:travel, :member=>trav_member, :date=>Date.today, :arrival=>false, :time=>Time.now, 
          :with_spouse=>true, :with_children=>true,
          :other_travelers=>'Grandparents')
      mail.body.encoded.should match(@travel.member.name)      
    end

    it "reports a changed travel record without member" do
      @travel = Factory.stub(:travel, :member=>nil, :date=>Date.today, :arrival=>false, :time=>Time.now, 
          :with_spouse=>true, :with_children=>true,
          :other_travelers=>'Santa Claus')
      mail.body.encoded.should match(@travel.other_travelers)      
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
      contacts = @head.primary_contact(:no_substitution=>true)
      contacts.should_not be_nil
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
      c.reload.is_primary.should be_true
      h = @head.health_data
      p = @head.personnel_data
      t = @head.most_recent_term      
      required_fields = [
         m.last_name, m.first_name, m.residence_location, m.ministry, m.status,
         m.work_location, m.country_name, m.ministry_comment,
         m.birth_date,
      #   h.bloodtype,
         p.education, p.date_active, p.est_end_of_service,
         t.start_date, t.end_date,
         c.email_1,  c.email_2, c.blog, c.photos,
         c.other_website, c.facebook,
         ]
      required_fields.each do |field| 
        summary.should match(Regexp.escape(field.to_s)) 
      end  
      summary.should match c.phone_1.phone_format
      summary.should match c.phone_2.phone_format
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

    it "does not show member's contact info as spouse's when spouse data is missing" do
      spouse = create_spouse(@head)
      summary = family_summary_content(@family)
      # The summary of missing data contains a line for missing data
      #   like "Sally: birth date; primary phone"
      summary.should match spouse.first_name    
      summary.should match MISSING_CONTACT
      summary.should match Regexp.new("#{spouse.first_name}: .*primary phone")
    end

    it 'includes child data' do
      child = Factory(:child, :family=>@family, :first_name=>'Sandy')
      summary = family_summary_content(@family)
      summary.should match 'CHILDREN'    
      summary.should match child.birth_date.to_s    
      summary.should match child.first_name    
      summary.should_not match 'SPOUSE'    
    end

    describe 'for those on field' do
      before(:each) {@current = Factory(:field_term_current, :member=>@head)}      

      it 'requires end of current term' do
        @head.most_recent_term.should == @current
        missing = family_missing_info(@family).join("\n")
        missing.should match("estimated end of current term")
      end

      it 'does not requires start of next term' do
        @head.most_recent_term.should == @current
        missing = family_missing_info(@family).join("\n")
        missing.should_not match("estimated start of next term")
      end

    end #for those on the field

    describe 'for those on home assignment' do
      before(:each) do 
        @current = Factory(:field_term_current, :member=>@head)
        home = Factory(:status_home_assignment)
        @head.update_attribute(:status, home)
      end        

      it 'does not require end-of-current-term' do
        @head.most_recent_term.should == @current
        missing = family_missing_info(@family).join("\n")
        missing.should_not match("estimated end of current term")
      end

      it 'does require start-of-next-term' do
        missing = family_missing_info(@family).join("\n")
        missing.should match("estimated start of next term")
        pending = Factory(:field_term_future, :member=>@head) # create a pending term with est_start_date
        @head.reload.pending_term.should == pending
        missing = family_missing_info(@family).join("\n")
        missing.should_not match("estimated start of next term")
     end
    end # for those on home assignment

  end

  describe 'travel_reminder' do
    before(:each) do
      @travel = Factory.stub(:travel, :arrival=>true, :time=>sixpm, :personal=>true,
        :return_date=>nil, :return_time=>nil)
      Factory(:contact, :member=>@travel.member)
    end
    
    it 'creates a reminder email' do
      message = Notifier.travel_reminder(@travel).to_s
      message.should match "To: #{@travel.member.email}"
      message.should match "From: #{Settings.email.travel}"
      message.should match "[SIM Database #travel_reminder]"
    end

    it 'contains essentials of travel info' do
      message = Notifier.travel_reminder(@travel).to_s
      message.should match @travel.date.to_s
      message.should match @travel.time.strftime('%l:%M %P')
      message.should match "#{@travel.total_passengers}.*total|total.*#{@travel.total_passengers}"
      message.should match @travel.travelers
      message.should match "#{@travel.baggage} pieces"
      message.should match @travel.purpose_category
      message.should match @travel.guesthouse
      message.should_not match "Return trip"
      message.should_not match "own arrangements"
    end           

    it 'reports return trip if present' do
#      @travel.update_attributes(:return_date=>@travel.date+5.months, :return_time=>twopm)
      @travel.return_date = @travel.date+5.months
      @travel.return_time = twopm
      message = Notifier.travel_reminder(@travel).to_s
      message.should match "Return trip"
      message.should match twopm.strftime('%l:%M %P')
      message.should match @travel.return_date.to_s
    end
      
    it 'reports "own arrangements" if applicable' do
#      @travel.update_attributes(:own_arrangements=>true)
      @travel.own_arrangements = true
      message = Notifier.travel_reminder(@travel).to_s
      message.should match "own arrangements"
    end
      
  end

  describe "contact updates" do
    before(:each) do
      @member = Factory.stub(:member)
      @contact = Factory.stub(:contact, :member=>@member, :updated_at=>Time.now)
      @member.stub(:contacts).and_return([@contact])
    end

    it "includes contact name" do
      message = Notifier.contact_updates('mike@example.com', [@contact])
#puts "message => #{message}"
      message.to_s.should match @member.last_name
    end

    it "includes contact email" do
      message = Notifier.contact_updates('mike@example.com', [@contact])
      message.to_s.should match @contact.email_1
    end

    it "includes message if there are no updates" do
      message = Notifier.contact_updates('mike@example.com', [])
      message.to_s.should match "No changes"
    end


  end
end
