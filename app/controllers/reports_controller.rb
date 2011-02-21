# For generating different kinds of reports output to PDF
# Perhaps should be refactored so that each report is inside its own main model's controller?
class ReportsController < ApplicationController

  def index
  end


   # Blood Type Reports
   def bloodtypes
#puts "**** Bloodtype report, params = #{params}"
     params = {:format => 'pdf'}.merge(params || {}) 
puts "**** Bloodtype report, params[:format] = #{params[:format]}"
     selected = Member.select("family_id, last_name, first_name, middle_name, bloodtype_id, status_id")
     selected = selected.delete_if{|x| !x.on_field || x.bloodtype_id.nil? }   # delete members not on the field
     output = BloodtypeReport.new.to_pdf(selected,"Includes only those currently on the field")

     respond_to do |format|
       format.pdf do
        send_data output, :filename => "bloodtypes.pdf", 
                          :type => "application/pdf"
       end
     end
   end

  # Birthday reports
   def birthdays
    selected = Member.select("family_id, last_name, first_name, middle_name, short_name, birth_date, status_id")
    selected = selected.delete_if{|x| !x.active }   # delete members not on the field
    output = BirthdayReport.new.to_pdf(selected,"")

    respond_to do |format|
      format.pdf do
        send_data output, :filename => "birthdays.pdf", 
                          :type => "application/pdf"
      end
    end
  end
 
  def birthday_calendar
    selected = Member.select("family_id, last_name, first_name, middle_name, birth_date, status_id")
    calendar = CalendarMonthPdf.new(3,2010, :page_size=>"A4", :page_layout=>:landscape, :box=>true)
    msg = {}
    selected.each do |m|
      if m.birth_date && (m.birth_date.month == 3 )
#puts "adding #{m.short_name} to day #{m.birth_date.day}"
        msg[m.birth_date.day] ||= ''
        msg[m.birth_date.day] << "BD: " + m.full_name + "\n"
      end
    end
    msg.each do |day,names|  
        calendar.in_day(day) do
          calendar.move_down 11
          calendar.text names, :align=> :left, :valign=>:top, :size=>8
        end
    end    
    calendar.in_day(1) {calendar.text "1"}
    calendar.in_day(20) {calendar.stroke_bounds}

    respond_to do |format|
      format.pdf do
        send_data calendar.render, :filename => "calendar.pdf", 
                          :type => "application/pdf"
      end
    end
  end
 
  # Test showing how to generate tables with Prawn
   def tabletest
    selected = Member.select("family_id, last_name, first_name, bloodtype_id, status_id")
    selected = selected.delete_if{|x| !x.on_field || x.bloodtype_id.nil? }   # delete members not on the field
    output = TableTest.new.to_pdf(selected,"Includes only those currently on the field")

    respond_to do |format|
      format.pdf do
        send_data output, :filename => "tabletest.pdf", 
                          :type => "application/pdf"
      end
    end
  end

  # Test showing how to use multi-column layout with Prawn and our own (temporary?) flow_in_columns method
   def multi_col_test
    output = MultiColumnTest.new.to_pdf()

    respond_to do |format|
      format.pdf do
        send_data output, :filename => "test.pdf", 
                          :type => "application/pdf"
      end
    end
  end
end
