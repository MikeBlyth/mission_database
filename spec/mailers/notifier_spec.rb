require "spec_helper"
require 'sim_test_helper'
include SimTestHelper

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
    before(:each) do # Consider making this a before(:all)
      @status = Factory(:status)
      Factory(:contact_type)
      Factory(:country)
      @employment_status = Factory(:employment_status)
      @bloodtype = Factory(:bloodtype)
      @residence = Factory(:location)
      @family = Factory(:family, :status=>@status, :residence_location=>@residence)
      @head = @family.head
      add_details @family.head
      @spouse = create_spouse(@head)
      @kid = Factory.build(:child, :family=>@family) # Don't forget to save!
      @family2 = Factory(:family) 
      Factory(:contact, :member=>@head)
      Factory(:contact, :member=>@family2.head)
      Factory(:field_term, :member=>@head)
      Factory(:field_term, :member=>@spouse)
      @head.personnel_data.should_not be_nil
      @spouse.personnel_data.should_not be_nil
      @head.health_data.should_not be_nil
      @spouse.health_data.should_not be_nil
    end
    
    it 'sends email to each recipient' do
      lambda do
        Notifier.send_family_summary(Family.all)
      end.should change(ActionMailer::Base.deliveries, :length).by(Family.count)
    end
  end
      
end
