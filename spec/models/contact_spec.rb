include SimTestHelper

describe Contact do

  describe 'summary' do
  end
  
  describe 'summary_text' do
  end
  
  describe 'finds recent' do
    it {finds_recent(Contact)}
  end

  # TODO: Consolidate with phone_format tests in incoming_mails_controller and notifier specs
  describe "phone_format" do
    it {'08023456789'.phone_format.should == '0802 345 6789'}
    it {'0802-34-56789'.phone_format.should == '0802 345 6789'}
    it {'+2348023456789'.phone_format.should == '0802 345 6789'}
    it {'0802 3 45 6789'.phone_format.should == '0802 345 6789'}
  end

  describe "phone_std" do
    it {'08023456789'.phone_std.should == '+2348023456789'}
    it {'0802-34-56789'.phone_std.should == '+2348023456789'}
    it {'+2348023456789'.phone_std.should == '+2348023456789'}
    it {'+234-802.3456789'.phone_std.should == '+2348023456789'}
    it {'0802 3 45 6789'.phone_std.should == '+2348023456789'}
 #   it {'802 3 45 6789'.phone_std.should == '+2348023456789'}
    it {'+44802 3 45 6789'.phone_std.should == '+448023456789'}
    it {''.phone_std.should be_nil}
  end

  it 'standardizes phone numbers on save' do
    phone = "0803 333 3333"
    contact = Factory(:contact, :phone_1 => phone, :phone_2 => phone, :member=>Factory.stub(:member))
    contact.reload.phone_1.should == phone.phone_std
    contact.reload.phone_2.should == phone.phone_std
  end
    
end
