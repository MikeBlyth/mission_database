include SimTestHelper

describe Contact do

  describe 'summary' do
    pending
  end
  
  describe 'summary_text' do
    pending
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

  describe 'is_primary flag' do
    before(:each) {@member=Factory(:member_without_family)}
    
    describe 'on new record' do
      
      it 'is set if member is not defined for contact record' do
        Contact.new.is_primary.should be_true
      end 

      it 'is set on new record if there is NOT an existing primary contact for member' do
        Contact.new(:member=>@member).is_primary.should be_true
      end
    
      it 'is NOT set on new record if there IS existing primary contact for member' do
        Factory(:contact, :member=>@member, :is_primary=>true)
        Contact.new(:member=>@member).is_primary.should_not be_true
      end
      
      it 'is NOT set on new record when it is initialized as false' do
        Contact.new(:member=>@member, :is_primary=>false).is_primary.should be_false
      end
      
      it 'is NOT set on OLD record (one retrieved from db)' do
        f = Factory(:contact, :is_primary=>false, :member=>@member)
        f.reload.is_primary.should_not be_true
      end
      


    end # on new record
    
    describe 'on record being updated' do
      
      it "is cleared from other records when set in update parameters" do
        first = Factory(:contact, :member=>@member, :is_primary=>true)
        second = Factory(:contact, :member=>@member, :is_primary=>false)
        first.reload.is_primary.should be_true
        second.reload.is_primary.should be_false
        second.update_attributes(:member=>@member, :is_primary=>true)
        first.reload.is_primary.should be_false
        second.reload.is_primary.should be_true
      end 

      it "is NOT cleared from other records when NOT set in update parameters" do
        first = Factory(:contact, :member=>@member, :is_primary=>true)
        second = Factory(:contact, :member=>@member, :is_primary=>false)
        first.reload.is_primary.should be_true
        second.reload.is_primary.should be_false
        second.update_attributes(:member=>@member, :is_primary=>false)
        first.reload.is_primary.should be_true
        second.reload.is_primary.should be_false
      end 

    end # on record being updated
      
  end     # is_primary flag
end
