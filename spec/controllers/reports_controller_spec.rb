require 'spec_helper'
#require "webrat"

#Webrat.configure do |config|
#  config.mode = :rails
#end

describe ReportsController do
include ApplicationHelper

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
  
  describe "calendar reports" do
  
    it "merges data hashes correctly" do
      birthdays = {1 => {:text => "BD: John\n", :font_size=>12}, 4 => {:text => "BD: Mary\nBD: Joan\n", :align=> :center} }
      travels = {1 => {:text => "AR: Arin\n", :font_size=>14, :align=>:center}, 2 => {:text=>"DP: Jack\n", :font_size=>8},
                 4 => {:text => "DP: Oren\n", :align=>:right} }
      ReportsController.send(:public, *ReportsController.private_instance_methods)
      merged = controller.merge_calendar_data( [birthdays, travels] )           
      merged[1][:text].should == birthdays[1][:text] + travels[1][:text]
      merged[1][:font_size].should == birthdays[1][:font_size]
      merged[1][:align].should == travels[1][:align]
      #
      merged[2][:text].should == travels[2][:text]
      merged[2][:font_size].should == travels[2][:font_size]
      #
      merged[4][:text].should == birthdays[4][:text] + travels[4][:text]
      merged[4][:font_size].should == nil
      merged[4][:align].should == birthdays[4][:align]
    end
    
  end # describe "calendar reports"  

  describe "smart_join" do  # This isn't really in reports_controller, but in application_helper.
    it "works" do
      smart_join([' a ', '', nil, 25, "\ncat\t\n"]).should == "a, 25, cat"
      smart_join([' a ', '', nil, 25, "\ncat\t\n"], "::").should == "a::25::cat"
    end
  end  
    

end # describe ReportsController

