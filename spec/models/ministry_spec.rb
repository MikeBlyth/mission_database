describe Ministry do
  include SimTestHelper

  describe "check before destroy:" do

    it "does destroy only if there are no existing linked member records" do
      test_check_before_destroy(:ministry, :member)
    end

    it "does destroy only if there are no existing linked family records" do
      test_check_before_destroy(:ministry, :field_term)
    end

  end # check before destroy
      
end

