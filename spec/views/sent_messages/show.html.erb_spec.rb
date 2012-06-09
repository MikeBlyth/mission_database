require 'spec_helper'

describe "sent_messages/show.html.erb" do
  before(:each) do
    @sent_message = assign(:sent_message, stub_model(SentMessage,
      :message_id => 1,
      :member_id => 1,
      :status => 1,
      :delivery_modes => "Delivery Modes",
      :confirmed_mode => "Confirmed Mode",
      :confirmation_message => "Confirmation Message"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Delivery Modes/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Confirmed Mode/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Confirmation Message/)
  end
end
