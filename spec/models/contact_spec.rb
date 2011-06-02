include SimTestHelper

describe Contact do

  describe 'summary' do
  end
  
  describe 'summary_text' do
  end
  
  it {finds_recent(Contact)}

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
    it {'802 3 45 6789'.phone_std.should == '+2348023456789'}
    it {'+44802 3 45 6789'.phone_std.should == '+448023456789'}
  end
end
