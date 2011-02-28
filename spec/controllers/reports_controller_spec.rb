require 'spec_helper'
require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

describe ReportsController do
 
  reports = %w(bloodtypes birthdays birthday_calendar phone_email travel_schedule)
  describe "authentication before controller access" do

    describe "for non-signed-in users" do
    
      it 'does not allow access to reports' do
        reports.each do |report|
          puts "\tChecking #{report}"
          get report
          response.should redirect_to(signin_path) 
        end  
      end

    end #  "for non-signed-in users" 
  end # "authentication before controller access"
  
end # describe ReportsController

