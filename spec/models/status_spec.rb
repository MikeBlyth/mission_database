describe Status do
  include SimTestHelper

  describe "check before destroy:" do

    it "does destroy only if there are no existing linked member records" do
      test_check_before_destroy(:status, :member)
    end

    it "does destroy only if there are no existing linked family records" do
      test_check_before_destroy(:status, :family)
    end

  end # check before destroy

  it "returns array of status id's for on-field status" do
    field_1 = Factory(:status, :on_field=>true).id
    Factory(:status, :on_field=>false)
    field_2 = Factory(:status, :on_field=>true).id
    Factory(:status, :on_field=>false)
    field_3 = Factory(:status, :on_field=>true).id
    Factory(:status, :on_field=>false)
    Status.field_statuses.sort.should == [field_1, field_2, field_3]
  end  

  it "returns array of status id's for active status" do
    field_1 = Factory(:status, :active=>true).id
    Factory(:status, :active=>false)
    field_2 = Factory(:status, :active=>true).id
    Factory(:status, :active=>false)
    field_3 = Factory(:status, :active=>true).id
    Factory(:status, :active=>false)
    Status.active_statuses.sort.should == [field_1, field_2, field_3]
  end  

      
end

