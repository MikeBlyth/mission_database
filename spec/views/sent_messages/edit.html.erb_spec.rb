require 'spec_helper'

describe "sent_messages/edit.html.erb" do
  before(:each) do
    @sent_message = assign(:sent_message, stub_model(SentMessage,
      :message_id => 1,
      :member_id => 1,
      :status => 1,
      :delivery_modes => "MyString",
      :confirmed_mode => "MyString",
      :confirmation_message => "MyString"
    ))
  end

  it "renders the edit sent_message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sent_messages_path(@sent_message), :method => "post" do
      assert_select "input#sent_message_message_id", :name => "sent_message[message_id]"
      assert_select "input#sent_message_member_id", :name => "sent_message[member_id]"
      assert_select "input#sent_message_status", :name => "sent_message[status]"
      assert_select "input#sent_message_delivery_modes", :name => "sent_message[delivery_modes]"
      assert_select "input#sent_message_confirmed_mode", :name => "sent_message[confirmed_mode]"
      assert_select "input#sent_message_confirmation_message", :name => "sent_message[confirmation_message]"
    end
  end
end
