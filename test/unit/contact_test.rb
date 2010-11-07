require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  # Replace this with your real tests.

#  this doesn't work yet
#  test "object creation" do
#    createit(Contact, {:member_id=>1}, :member_id)
#  end



  test "email" do
    # should allow blank
    contact = Contact.new(:member_id=>1, :email_1=>'')
    assert_valid(contact,"Correct email_1 flagged as invalid")
    # should allow valid
    contact.email_1 = 'mb@sim.org'
    assert_valid(contact,"Correct email_1 flagged as invalid")
    # should not allow invalid
    contact.email_1 = 'mb@sim'
    assert_not_valid(contact,"Invalid email not trapped")
    # Do the same with email_2 (for better abstraction, write a test to cover all...
    contact = Contact.new(:member_id=>1, :email_2=>'')
    assert_valid(contact,"Correct email_2 flagged as invalid")
    contact.email_2 = 'mb@sim.org'
    assert_valid(contact,"Correct email_2 flagged as invalid")
    contact.email_2 = 'mb@sim'
    assert_not_valid(contact,"Invalid email_2 not trapped")
    
  end

  test "valid member_id" do
    contact = Contact.new(:member_id=>1, :email_1=>'email@test.com')
    assert_presence_required(contact, :member_id)
    assert_equal(contact.member.last_name,members(:one).last_name)
  end

  test "invalid member_id" do
    contact = Contact.new(:member_id=>1)
    assert_parent_required(contact, :member_id, 98765)
  end

end
