require 'spec_helper'

describe "messages/new.html.erb" do
  before(:each) do
    assign(:message, stub_model(Message,
      :body => "MyString",
      :from_id => 1,
      :code => "MyString",
      :confirm_time_limit => 1,
      :retries => 1,
      :retry_interval => 1,
      :expiration => 1,
      :response_time_limit => 1,
      :importance => 1,
      :to_groups => "MyString"
    ).as_new_record)
  end

  it "renders new message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => messages_path, :method => "post" do
      assert_select "input#message_body", :name => "message[body]"
      assert_select "input#message_from_id", :name => "message[from_id]"
      assert_select "input#message_code", :name => "message[code]"
      assert_select "input#message_confirm_time_limit", :name => "message[confirm_time_limit]"
      assert_select "input#message_retries", :name => "message[retries]"
      assert_select "input#message_retry_interval", :name => "message[retry_interval]"
      assert_select "input#message_expiration", :name => "message[expiration]"
      assert_select "input#message_response_time_limit", :name => "message[response_time_limit]"
      assert_select "input#message_importance", :name => "message[importance]"
      assert_select "input#message_to_groups", :name => "message[to_groups]"
    end
  end
end
