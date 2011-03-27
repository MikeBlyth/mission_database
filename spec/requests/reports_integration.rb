require 'spec_helper'
require 'sim_test_helper'
include SimTestHelper

def pdf_to_text
  temp_pdf = Tempfile.new('pdf')
  temp_pdf << page.body.force_encoding('UTF-8')
  temp_pdf.close
  page.driver.instance_variable_set('@body', `pdftotext -enc UTF-8 -q #{temp_pdf.path} - 2>&1`)
end

describe "Reports" do
  
  before(:each) do
    integration_test_sign_in(:admin=>true)
  end   

  describe "'Where Is' report" do
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
#      @member = Factory(:member, :residence_location_id=>@residence.id,
#                :status_id=>@on_field.id,
#                :work_location_id => @work.id,
#                :temporary_location => @temp_location,
#                :temporary_location_from_date => Date.today - 1.week,
#                :temporary_location_until_date => Date.today - 5.days)
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

    it "reports residence location if no overrides" do
      visit reports_path # whereis_report_path
      click_link "Where is everyone?"
      pdf_to_text
      page.should have_content(@member.last_name)
      page.should have_content(@member.residence_location.description)
      page.should_not have_content('ravel')
    end

    it "reports outgoing travel of on-field member" do
      @travel.update_attribute(:return_date, Date.tomorrow)
      visit reports_path # whereis_report_path
      click_link "Where is everyone?"
      pdf_to_text
      page.should have_content(@member.last_name)
      page.should have_content('ravel')
    end

    it "reports outgoing travel of on-field spouse" do
      @travel.update_attributes(:return_date=>Date.tomorrow, :with_spouse=>true)
      spouse = Member.create(@member.attributes.merge({:spouse=>@member, :first_name=>'Sally',
           :sex=>@member.other_sex, :name=>"#{@member.last_name}, Sally"}))
      visit reports_path # whereis_report_path
      click_link "Where is everyone?"
      pdf_to_text
      (page.driver.body =~ /Sally.*ravel/m).should_not be_nil
    end


    it "reports incoming travel of off-field member " do
      @travel.update_attributes(:return_date=>Date.tomorrow, :arrival=>true)
      status = Factory(:status, :on_field=>false, :active=>false)
      @member.update_attribute(:status, status)   # Make member not active and not on field
      visit reports_path # whereis_report_path
      click_link "Where is everyone?"
      pdf_to_text
      page.should have_content(@member.last_name)
      page.should have_content('ravel')
    end

  end

end
