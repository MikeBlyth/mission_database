require 'spec_helper'
require '~/simjos/spec/support/sim_test_helper'
include SimTestHelper

describe "Report" do
  
  before(:each) do
    integration_test_sign_in(:admin=>true)
  end   

  describe "Calendar" do
    pending  
  end

  describe "'Where Is' " do
    before(:each) do
      # Defaults are set so that temporary_location and a travel record both exist but
      # their dates do not include today. In testing, change the :...until_date or :return_date
      # to tomorrow, and the new locations should be in effect.
      @on_field = Factory(:status)
      @temp_location = 'Abuja Hilton'
      @travel_location = 'Paris'
      @residence = Factory(:location, :description=>'Jos')
      @work = Factory(:location, :description=>'Gidan Bege')
      @location_unspecified = Factory(:location_unspecified)
      @member = factory_member_create(:residence_location_id=>@residence.id,
                :status_id=>@on_field.id,
                :work_location_id => @work.id,
                :temporary_location => @temp_location,
                :temporary_location_from_date => Date.today - 1.week,
                :temporary_location_until_date => Date.today - 5.days)

      @travel = Factory(:travel, :date  => Date.today - 1.week,     
                 :return_date => Date.today - 5.days,
                 :destination=> @travel_location,
                 :origin => 'Abuja', :arrival => false, :member_id => @member.id) 
    end

    # Covered in new report tests or in travel
#    it "reports residence location if no overrides", :slow=>true do
#      visit reports_path # whereis_report_path
#      click_link "whereis-detailed-pdf"
#      pdf_to_text
#      page.should have_content(@member.last_name)
#      page.should have_content(@member.residence_location.description)
#      page.should_not have_content('return')
#    end

#    it "reports outgoing travel of on-field member", :slow=>true do
#      @travel.update_attribute(:return_date, Date.today+5.days)
#      visit reports_path # whereis_report_path
#      click_link "whereis-detailed-pdf"
#      pdf_to_text
#      page.should have_content(@member.last_name)
#      page.should have_content('return')
#    end

#    it "reports outgoing travel of on-field spouse", :slow=>true do
#      @travel.update_attributes(:return_date=>Date.today+5.days, :with_spouse=>true)
#      @member.create_wife({:first_name=>'Sally', :name=>"#{@member.last_name}, Sally"})
#      visit reports_path # whereis_report_path
#      click_link "whereis-detailed-pdf"
#      pdf_to_text
##puts page.driver.body
##      (page.driver.body =~ /Sally.*ravel/m).should_not be_nil
#      page.should have_content('return')
#    end

#    it "reports incoming travel of off-field member ", :slow=>true do
#      @travel.update_attributes(:return_date=>Date.today+5.days, :arrival=>true)
#      status = Factory(:status, :on_field=>false, :active=>false)
#      @member.update_attribute(:status, status)   # Make member not active and not on field
#      visit reports_path # whereis_report_path
#      click_link "whereis-detailed-pdf"
#      pdf_to_text
##puts page.driver.body
#      page.should have_content(@member.last_name)
#      page.should have_content(@member.travel_location)
#    end

#    it "reports location of person with 'on-field' visitor status", :slow=>true do
#      visitor_status = Factory(:status, :on_field=>true, :active=>false)
#      @member.update_attribute(:status, visitor_status)   # Make member on field but not active
#      visit reports_path # whereis_report_path
#      click_link "whereis-detailed-pdf"
#      pdf_to_text
#      page.should have_content(@member.last_name)
#      page.should_not have_content('ravel')
#    end
#    
#    it "reports location of someone not in database but in travel record", :slow=>true do
#      @travel.update_attributes(:return_date=>Date.tomorrow, :arrival=>true, :member=>nil, 
#          :other_travelers=>"Santa Claus")
#      visit reports_path # whereis_report_path
#      click_link "whereis-detailed-pdf"
#      pdf_to_text
#      page.should have_content("Santa Claus")
#      page.should have_content('isitor')
#    end

  end # Where Is
  
  describe 'Contact Update' do
    before(:each) do
      integration_test_sign_in(:admin=>true)
    end   

    it 'includes Send button' do
      visit contact_updates_path
      page.should have_button('Send')
    end
  end # 'Contact Update'

end
