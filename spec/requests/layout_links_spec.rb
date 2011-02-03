require 'spec_helper'
  require "webrat"

  Webrat.configure do |config|
    config.mode = :rails
  end

describe "LayoutLinks" do
  it "should have a signup page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign up")
  end
end

