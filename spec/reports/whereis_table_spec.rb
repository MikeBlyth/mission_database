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

      @travel = Factory.build(:travel, :date  => Date.today - 1.week,     
                 :return_date => Date.today - 5.days,
                 :destination=> @travel_location,
                 :origin => 'Abuja', :arrival => false, :member => @member) 
      @family = @member.family
      @family.residence_location = @residence
      @table = WhereIsTable.new
    end


    it "creates pdf file" do
      puts @table.family_data_line(@family)
    end

  end # check before destroy
      
end

