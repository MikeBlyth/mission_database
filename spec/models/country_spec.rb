describe Country do
  include SimTestHelper


  describe "check before destroy:" do

    it "does destroy only if there are no existing linked records" do
      test_check_before_destroy(:country, :member)
    end

  end # check before destroy
      
end

