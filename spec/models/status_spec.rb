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
    Status.field_statuses.should =~ [field_1, field_2, field_3]
  end  

  it "returns array of status id's for active status" do
    active_1 = Factory(:status, :active=>true).id
    Factory(:status, :active=>false)
    active_2 = Factory(:status, :active=>true).id
    Factory(:status, :active=>false)
    active_3 = Factory(:status, :active=>true).id
    Factory(:status, :active=>false)
    Status.active_statuses.should =~ [active_1, active_2, active_3]
  end  

  describe 'statuses_by_category' do
    it 'returns status ids responding to category' do
      inactive_field = Factory(:status, :active=>false, :on_field=>true).id
      inactive_home  = Factory(:status, :active=>false, :on_field=>false )
      active_home = Factory(:status, :active=>true, :on_field=>false).id
      active_field = Factory(:status, :active=>true, :on_field=>true).id
      Status.statuses_by_category('on_field').should =~ [inactive_field, active_field]
      Status.statuses_by_category('active').should =~ [active_home, active_field]
      Status.statuses_by_category('active OR on_field').should =~ [active_home, active_field, inactive_field]
    end    
  end    
end

