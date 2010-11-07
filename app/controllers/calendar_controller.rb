class CalendarController < ApplicationController
   # Blood Type Reports
  def index
#    output = CalendarReport.new(:page_size=>"A4", :page_layout=>:landscape).to_pdf(11,2010)
#    page = CalendarReport.new(:page_size=>"A4", :page_layout=>:landscape)
    
#    output = page.render
    output = CalendarMonthPdf.new(10,2010, :page_size=>"A4", :page_layout=>:landscape, :box=>true)

    
    respond_to do |format|
      format.pdf do
        send_data output.render, :filename => "calendar.pdf", 
                          :type => "application/pdf"
      end
      
    end
  end
end