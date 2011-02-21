# For generating different kinds of reports output to PDF
# Perhaps should be refactored so that each report is inside its own main model's controller?
class ReportsController < ApplicationController

  def index
    # this just displays a view that lets the user select from reports
  end

   # Blood Type Reports
   def bloodtypes
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
    # Settings
    page_size = params[:page_size] || Settings.reports.page_size
    if params[:date].respond_to?(:month)
      date = params[:date]
    else
      next_m = Date::today().next_month
      date = Date.new(next_m.year, next_m.month, 1)
    end
    page_layout = params[:page_layout] || :landscape
    box = params[:box] || true
    prefix = Settings.reports.birthday_calendar.birthday_prefix # Something like "BD: " or icon of a cake, to precede each name

    # Select the people born this month and to put on the calendar
    selected = Member.select("family_id, last_name, first_name, middle_name, birth_date, status_id")
    calendar = CalendarMonthPdf.new(:date=>date, :page_size=>page_size, :page_layout=>page_layout, :box=>box)

    # Make a hash like { 1 => "BD: John Doe\nBD: Mary Smith", 8 => "BD: Adam Smith\n"}
    msg = {}
    selected.each do |m|
      if m.birth_date && (m.birth_date.month == 3 ) # Select people who were born in this month
        msg[m.birth_date.day] ||= ''
        msg[m.birth_date.day] << prefix + m.full_name + "\n" 
      end
    end

    # Actually print the strings
    msg.each do |day,names|  # For each day with birthdays, print the names list. 
        calendar.in_day(day) do
          calendar.move_down 11
          calendar.text names, :align=> :left, :valign=>:top, :size=>8
        end
    end    
    # calendar.in_day(1) {calendar.text "1"} # Just an example of how to write text in the box
    # calendar.in_day(20) {calendar.stroke_bounds} # Just an example of drawing a box inside the calendar date box

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
