require 'spec_helper'

# Make record an orphan by deleting its parent member.
# Since we use delete rather than destroy, member's child records should not
# be deleted.
def make_orphan(record)
  m =  Member.find_by_id(record.member_id)
  m.delete if m
  record.reload
end  

describe AdminController do
  
  describe 'database cleaner' do
    before :each do
    end
    
    describe 'members' do
      before :each do
        @member = Factory.build(:member, :family=>Factory(:family), 
              :first_name => "First", :last_name=>"Last", :name=>"Last, First"
              )
        params= {:fix=>true}      
      end

      it "does not complain about member with nil optional associations" do
        @member.save
        controller.clean_members.should =~ /no errors/
      end  

      it "does not change _id when fix is set to false" do
        @object = @member
        @object.status_id = 999
        @object.save
        controller.clean_members(false)
        @object.reload.status_id.should == 999
      end  
        
      it "does not complain about member with valid associations" do
        @member.status = Factory(:status)
        @member.country = Factory(:country)
        @member.work_location = Factory(:location)
        @member.residence_location = Factory(:location)
        @member.spouse = Factory(:member, :sex=>@member.other_sex)
        @member.ministry = Factory(:ministry)
        @member.save
        controller.clean_members(true).should =~ /no errors/
        @member.reload
        @member.status.should_not be_nil
        @member.country.should_not be_nil
        @member.work_location.should_not be_nil
        @member.residence_location.should_not be_nil
        @member.spouse.should_not be_nil
        @member.ministry.should_not be_nil
      end  

      it "removes invalid association" do
        @member.save
        %w(status country work_location residence_location spouse ministry).each do |link|
          @member.update_attribute(link+"_id", 999)
          controller.clean_members(true).should_not =~ /no errors/
          @member.reload.send(link+"_id").should be_nil
          # no need to reset link_id since it has been set to nil (or test fails)
        end  
      end  

      it "does not change timestamp when performing fixes" do
        long_ago = Time.new(2000,1,1)
        @member.update_attribute(:status_id, 900)
        @member.update_attribute(:updated_at,long_ago)
        @member.reload.updated_at.should == long_ago
        controller.clean_members(true)
        @member.reload.updated_at.should == long_ago
      end  

      it "it restores time stamping after running" do
        long_ago = Time.new(2000,1,1)
        @member.update_attribute(:status_id, 900)
        @member.update_attribute(:updated_at,long_ago)
        @member.reload.updated_at.should == long_ago
        controller.clean_members(true)
        @member.reload.updated_at.should == long_ago
        @member.update_attributes(:name => 'XYZ')
#        @member.update_attributes(:status => nil) # for some reason, this does not change time stamp!
        @member.reload.updated_at.should_not == long_ago
      end  



    end # describe members
    
    describe 'families' do
      before :each do
        @object = Factory.create(:family).reload
      end

      it "does not complain about object with nil optional associations" do
        # family.status_id and .residence_id are nil by default and should not cause a complaint
        controller.clean_families.should =~ /no errors/
      end  

      it "does not complain about family with valid associations" do
        @object.status = Factory(:status)
        @object.residence_location = Factory(:location)
        @object.save
        controller.clean_families(true).should =~ /no errors/
        @object.reload
        @object.status.should_not be_nil
        @object.residence_location.should_not be_nil
      end  

      it "does not change _id when fix is set to false" do
        @object.status_id = 999
        @object.save
        controller.clean_families(false)
        @object.reload.status_id.should == 999
      end  
        
      it "removes invalid association" do
        @object.save
        %w(status residence_location head).each do |link|
          @object.update_attribute(link+"_id", 999)
          controller.clean_families(true).should_not =~ /no errors/
          @object.reload.send(link+"_id").should be_nil
          # no need to reset link_id since it has been set to nil (or test fails)
        end  
      end  

    end # describe families
    
    describe 'field terms' do
      before :each do
        # Creates a member for .member_id but nil for other _id's
        @object = Factory.create(:field_term_empty, :start_date=>Date.today).reload
      end

      it "does not complain about object with nil optional associations" do
        controller.clean_field_terms.should =~ /no errors/
      end  

      it "does not complain about field term with valid associations" do
        @object.primary_work_location = Factory(:location)
        @object.employment_status = Factory(:employment_status)
        @object.ministry = Factory(:ministry)
        @object.save
        controller.clean_field_terms(true).should =~ /no errors/
        @object.reload
        @object.primary_work_location.should_not be_nil
        @object.employment_status.should_not be_nil
        @object.ministry.should_not be_nil
      end  

      it "does not change invalid _id when fix is set to false" do
        @object.ministry_id = 999
        @object.save
        controller.clean_field_terms(false)
        @object.reload.ministry_id.should == 999
      end  
        
      it "removes invalid association when fix is set to true" do
        %w(employment_status primary_work_location ministry).each do |link|
          @object.update_attribute(link+"_id", 999)
          controller.clean_field_terms(true).should_not =~ /no errors/
          @object.reload.send(link+"_id").should be_nil
          # no need to reset link_id since it has been set to nil (or test fails)
        end  
      end  

      it "does not delete records with bad links but valid parent" do
        @object.ministry_id = 999
        @object.save
        lambda do
          controller.clean_field_terms(true)
        end.should_not change(FieldTerm, :count)
      end        
      
      it "reports orphan records (no member) and does not delete them when fix is false" do
        make_orphan(@object)
        lambda do
          controller.clean_field_terms(false).should_not =~ /no errors/
        end.should_not change(FieldTerm, :count)
      end      

      it "reports orphan records and deletes them when fix is true" do
        make_orphan(@object)
        lambda do
          controller.clean_field_terms(true).should_not =~ /no errors/
        end.should change(FieldTerm, :count).by -1
      end      

    end # describe field terms
    
    describe 'contacts' do
      before :each do
        @contact_type = Factory.stub(:contact_type)
        @object = Factory(:contact, :phone_1 => "+2348081234567", :phone_2=>nil)
        @raw_phone = '08031234567'
        @no_zero = '8031234567'
      end

      it 'complains about non-std phone numbers' do
        @object.update_attribute(:phone_1, @raw_phone)
        controller.clean_contacts(false).should =~ /Standardized phone/i
      end

      it 'complains about phone numbers w/o country code or prefix-0' do
        @object.update_attribute(:phone_1, @no_zero)
        controller.clean_contacts(false).should =~ /country code/i
      end

      it 'fixes non-std phone numbers' do
        @object.update_attribute(:phone_1, @raw_phone)
        controller.clean_contacts(true).should =~ /Standardized phone/i
        @object.reload.phone_1.should == @raw_phone.phone_std
      end

      it 'accepts std phone numbers' do
        controller.clean_contacts(false).should =~ /no errors/
      end

      it "does not complain about object with nil optional associations" do
        @object.update_attribute(:contact_type_id, nil)
        @object.reload.contact_type_id.should == nil
        controller.clean_contacts.should =~ /no errors/
      end  

      it "does not complain about object with valid associations" do
        controller.clean_contacts.should =~ /no errors/
      end  

      it "does not change invalid _id when fix is set to false" do
        @object.update_attribute(:contact_type_id, 999)
        controller.clean_contacts(false)
        @object.reload.contact_type_id.should == 999
      end  
        
      it "removes invalid association when fix is set to true" do
        @object.update_attribute(:contact_type_id, 999)
        controller.clean_contacts(true)
        @object.reload.contact_type_id.should == nil
      end  

      it "does not delete records with bad contact_type but valid parent" do
        @object.update_attribute(:contact_type_id, 999)
        lambda do
          controller.clean_contacts(true)
        end.should_not change(Contact, :count)
      end        
      
      it "reports orphan records (no member) and does not delete them when fix is false" do
        make_orphan(@object)
        @object.member.should be_nil
        lambda do
          controller.clean_contacts(false).should_not =~ /no errors/
        end.should_not change(Contact, :count)
      end      

      it "reports orphan records and deletes them when fix is true" do
        make_orphan(@object)
        lambda do
          controller.clean_contacts(true).should_not =~ /no errors/
        end.should change(Contact, :count).by -1
      end      

      it "removes leading and trailing whitespace from email addresses" do
        @object.update_attribute(:email_1, " test@example.com \t")
        controller.clean_contacts(true).should =~ /blanks/
        @object.reload.email_1.should == "test@example.com"
      end  

      it "does not change timestamp when performing fixes" do
        long_ago = Time.new(2000,1,1)
        @object.update_attributes(:email_1=>" test@example.com \t")
        @object.update_attribute(:updated_at,long_ago)
        @object.reload.updated_at.should == long_ago
        controller.clean_contacts(true)
        @object.reload.updated_at.should == long_ago
      end  

      it "it restores time stamping after running" do
        long_ago = Time.new(2000,1,1)
        @object.update_attributes(:email_1=>" test@example.com \t")
        @object.update_attribute(:updated_at,long_ago)
        controller.clean_contacts(true)
        @object.reload.updated_at.should == long_ago
        @object.update_attributes(:email_1=>nil)
        @object.reload.updated_at.should_not == long_ago
      end  

    end # describe contacts
    
    describe 'locations' do
      before :each do
        @object = Factory.create(:location).reload
      end

      it "does not complain about valid location" do
        controller.clean_locations.should =~ /no errors/
      end          

      it "complains about (but doesn't change) location without city" do
        @object.update_attribute(:city, nil)
        controller.clean_locations.should_not =~ /no errors/
        @object.reload.city_id.should be_nil
      end  

      it "complains about (but doesn't change) object with invalid city" do
        @object.update_attribute(:city_id, 999)
        controller.clean_locations.should_not =~ /no errors/
        @object.reload.city_id.should == 999
      end  

    end # describe locations
        
  end # database cleaner

  describe 'notices:' do
    before(:each) do
      @user = Factory.stub(:user, :admin=>true)
      test_sign_in(@user)
    end
      
    describe 'family summaries' do
      before(:each) do
        # Have to have an employment status because the summary uses it
        @employment_status=Factory(:employment_status)
      end        

      it 'are reviewed' do
        2.times do  # create two families
          family = Factory(:family_active)
          head = Factory(:member, :family=> family)
          family.update_attribute(:head, head)
          Factory(:contact, :member=>head)
        end
        Factory(:family_active, :last_name => "Aa")
        Family.those_active.count.should == 3
        get :review_family_summaries
        response.should render_template('review_family_summaries')
        assigns[:families].should == Family.those_active.sort
      end

      it 'are emailed' do
        2.times do  # create two families
          family = Factory(:family_active)
          head = Factory(:member, :family=> family)
          family.update_attribute(:head, head)
          Factory(:contact, :member=>head)
          family.head.personnel_data.update_attribute(:employment_status, @employment_status)
        end
        Family.those_active.count.should == 2
        lambda {post :send_family_summaries}.should change(ActionMailer::Base.deliveries, :length).by(2)
      end

      it 'review does not mark summary_sent date' do
        family = Factory(:family)
        head = Factory(:member, :family=> family)
        family.update_attribute(:head, head)
        # Try to get around this update!
        family.head.personnel_data.update_attribute(:employment_status, @employment_status)
        get :review_family_summaries
        family.reload.summary_sent.should be_nil
      end

      it 'mailing mark summary_sent date' do
        family = Factory(:family_active)
        head = Factory(:member, :family=> family)
        family.update_attribute(:head, head)
        # Try to get around this update!
        head.personnel_data.update_attribute(:employment_status, @employment_status)
        Factory(:contact, :member=>head)
        post :send_family_summaries
        family.reload.summary_sent.should == Date.today
      end

      it 'are emailed if a summary was not sent recently' do
        family = Factory(:family_active, :summary_sent => nil)
        head = Factory(:member, :family=> family)
        family.update_attribute(:head, head)
        # Try to get around this update!
        family.head.personnel_data.update_attribute(:employment_status, @employment_status)
        Factory(:contact, :member=>head)
        lambda {post :send_family_summaries}.should change(ActionMailer::Base.deliveries, :length).by(1)
      end        

      it 'are not emailed if a summary was sent recently' do
        family = Factory(:family_active, :summary_sent => Date.today - 1.day)
        # Try to get around this update!
        head = Factory(:member, :family=> family)
        family.update_attribute(:head, head)
        head.personnel_data.update_attribute(:employment_status, @employment_status)
        Factory(:contact, :member=>family.head)
        post :send_family_summaries
        lambda {post :send_family_summaries}.
           should_not change(ActionMailer::Base.deliveries, :length)
      end        

    end # family summaries
    
    describe 'travel reminders' do
      
      it 'are reviewed' do
        member = Factory(:member)
        Factory(:contact, :member=>member)
        Factory(:travel, :member=>member)
        get :review_travel_reminders
        response.should render_template('review_travel_reminders')
        assigns[:travels].should == Travel.pending
      end

      it 'are emailed' do
        member = Factory(:member)
        Factory(:contact, :member=>member)
        Factory(:travel, :member=>member)
        lambda {post :send_travel_reminders}.should   # should send one email to each of two families 
          change(ActionMailer::Base.deliveries, :length).by(1)
      end

      it 'review does not mark reminder sent' do
        member = Factory(:member)
        Factory(:contact, :member=>member)
        travel = Factory(:travel, :member=>member)
        get :review_travel_reminders
        travel.reminder_sent.should be_nil
      end

      it 'sending email does mark reminder sent date' do
        member = Factory(:member)
        Factory(:contact, :member=>member)
        travel = Factory(:travel, :member=>member)
        post :send_travel_reminders
        travel.reload.reminder_sent.should == Date.today
      end

      it 'by default does not resend reminders' do
        member = Factory(:member)
        Factory(:contact, :member=>member)
        travel = Factory(:travel, :member=>member, :reminder_sent=>Date.today-1.week)
        lambda {post :send_travel_reminders}.   # should send one email to each of two families 
           should_not change(ActionMailer::Base.deliveries, :length)
      end
      
    end # travel reminders
  end # notices
  
end # AdminController
