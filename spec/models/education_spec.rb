describe Education do
  include SimTestHelper


  describe "check before destroy:" do

    it "does destroy only if there are no existing linked records" do
      test_check_before_destroy(:education, :personnel_data)
    end
    
  end # check before destroy
      
end

