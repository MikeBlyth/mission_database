require 'spec_helper'

describe "jqueries/new.html.erb" do
  before(:each) do
    assign(:jquery, stub_model(Jquery).as_new_record)
  end

  it "renders new jquery form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => jqueries_path, :method => "post" do
    end
  end
end
