require 'spec_helper'

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
      @temp_location = 'Abuja Hilton'
      @travel_location = 'Paris'
      @residence = Factory(:location, :description=>'Jos')
      @work = Factory(:location, :description=>'Gidan Bege')
      @location_unspecified = Factory(:location_unspecified)
      @member = Factory(:member, :residence_location_id=>@residence.id,
                :work_location_id => @work.id,
                :temporary_location => @temp_location,
                :temporary_location_from_date => Date.today - 1.week,
                :temporary_location_until_date => Date.today - 5.days)
      @member.update_attribute(:residence_location, @residence)
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
    end

    it "reports travel location if travel overrides" do
      @travel.update_attribute(:return_date, Date.tomorrow)
      visit reports_path # whereis_report_path
      click_link "Where is everyone?"
      pdf_to_text
      page.should have_content(@member.last_name)
      page.should have_content(@travel_location)
      page.should_not have_content(@member.residence_location.description)
    end
  end

end
