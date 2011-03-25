describe EmploymentStatus do
  include SimTestHelper


  describe "check before destroy:" do

    it "does destroy only if there are no existing linked records" do
      test_check_before_destroy(:employment_status, :personnel_data)
    end
    
    it "does destroy only if there are no existing linked records" do
      test_check_before_destroy(:employment_status, :field_term)
    end
    
  end # check before destroy
      
end

