describe WhereIsTable do
  include SimTestHelper


  describe "Report" do
    before(:each) do
      @on_field = Factory.build(:status)
      @temp_location = 'Abuja Hilton'
      @travel_location = 'Paris'
      @residence = Factory.build(:location, :description=>'Jos')
      @work = Factory.build(:location, :description=>'Gidan Bege')
      @location_unspecified = Factory.build(:location_unspecified)
      @member = factory_member_build(
                :status=>@on_field,
                :work_location => @work,
                :temporary_location => @temp_location,
                :temporary_location_from_date => Date.today - 1.week,
                :temporary_location_until_date => Date.today - 5.days)

      @contact = Factory.build(:contact, :member=>@member, :is_primary=>true)
      @travel = Factory.build(:travel, :date  => Date.today - 1.week,     
                 :return_date => Date.today - 5.days,
                 :destination=> @travel_location,
                 :origin => 'Abuja', :arrival => false, :member => @member) 
      @family = @member.family
      @family.residence_location = @residence
      @table = WhereIsTable.new
      @member.stub(:primary_contact).and_return(@contact)
    end


#    it "{print stuff for testing}" do
#      puts @table.family_data_formatted(@family)
#      puts @table.family_data_line(@family, :location=>'long')
#    end

    it "reports residence location if no overrides" do
      report = pdf_string_to_text_string(@table.to_pdf [@family])
      report.should match(@member.last_name)
      report.should match(@member.residence_location.description)
      report.should_not match('return')
    end

    it "includes visitors" do
      arrival = Date.today-10
      departure = Date.today+5
      visitors = [{:names=>'Santa Claus', :contacts=>"North Pole", :arrival_date=> arrival, :departure_date=>departure}]
      report = pdf_string_to_text_string(@table.to_pdf [@family], visitors)
      # Of course this next match string will need to be changed if the list on the report is changed!
      report.should match("Santa Claus: North Pole arrived #{arrival.to_s(:short)},\s+depart #{departure.to_s(:short)}" )
    end

    # No need to test all the possible location results
    
    


  end # check before destroy
      
end

