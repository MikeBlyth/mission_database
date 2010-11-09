require 'spec_helper'

describe "jqueries/show.html.erb" do
  before(:each) do
    @jquery = assign(:jquery, stub_model(Jquery))
  end

  it "renders attributes in <p>" do
    render
  end
end
