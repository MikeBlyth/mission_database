require 'spec_helper'

describe "jqueries/edit.html.erb" do
  before(:each) do
    @jquery = assign(:jquery, stub_model(Jquery,
      :new_record? => false
    ))
  end

  it "renders the edit jquery form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => jquery_path(@jquery), :method => "post" do
    end
  end
end
