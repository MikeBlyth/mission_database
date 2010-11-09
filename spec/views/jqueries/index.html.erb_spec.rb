require 'spec_helper'

describe "jqueries/index.html.erb" do
  before(:each) do
    assign(:jqueries, [
      stub_model(Jquery),
      stub_model(Jquery)
    ])
  end

  it "renders a list of jqueries" do
    render
  end
end
