require 'spec_helper'

describe "sent_messages/index.html.erb" do
  before(:each) do
    assign(:sent_messages, [
      stub_model(SentMessage,
        :message_id => 1,
        :member_id => 1,
        :status => 1,
        :delivery_modes => "Delivery Modes",
        :confirmed_mode => "Confirmed Mode",
        :confirmation_message => "Confirmation Message"
      ),
      stub_model(SentMessage,
        :message_id => 1,
        :member_id => 1,
        :status => 1,
        :delivery_modes => "Delivery Modes",
        :confirmed_mode => "Confirmed Mode",
        :confirmation_message => "Confirmation Message"
      )
    ])
  end

  it "renders a list of sent_messages" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Delivery Modes".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Confirmed Mode".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Confirmation Message".to_s, :count => 2
  end
end
