# require 'prawn_extend'
require 'reports_helper'

# Prawn document to generate PDF for blood types
class BirthdayReport < Prawn::Document
include ReportsHelper
    def to_pdf(selected,comments)
    
     # selected is an array of Members (with only some columns defined)
     # first, sort the array by name
     selected.sort! {|x,y| x.last_name_first <=> y.last_name_first}
  #   table_data = [['Last name', 'First name', 'Blood type']]
    text_data = ''
    selected.each do |m|
      text_data << "#{m.last_name_first(:short=>true, :initial=>true)}:  " 
      if m.birth_date.blank?
        text_data << "unknown"
      else
        text_data << "<i>"+m.birth_date.to_s(:short)+"</i>"
      end
      text_data << "\n\n"
    end
    page_header(:title=>'Birthdays', :left=>'SIM Nigeria Reports')
    move_down 8
    flow_in_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>2, 
      :size=>12, :inline_format => true , :gutter=>15 
    # Now sort by birthdate (month and day only)
    # A bit awkward to sort since some dates are nil (unknown) and don't respond to date methods;
    # any dummy date we try to use to represent unknown will still have valid day & month!
    selected.sort! do |x,y| 
      if x.birth_date 
        xkey = (sprintf('%02d%02d', x.birth_date.month, x.birth_date.day) + x.last_name_first)
      else 
        xkey = "0000" << x.last_name_first
      end  
      if y.birth_date 
        ykey = (sprintf('%02d%02d', y.birth_date.month, y.birth_date.day) + y.last_name_first) 
      else 
        ykey = "0000" << y.last_name_first
      end  
      xkey <=> ykey
    end               
    text_data = ''
    current_month = ''
    selected.each do |m|
      if m.birth_date
        if current_month != (m.birth_date.month || 0)
          current_month = m.birth_date.month
          text_data << "\n<b>#{Date::MONTHNAMES[current_month]}</b>\n\n"
        end
        text_data << m.last_name_first(:short=>true, :initial => true) << " (#{m.birth_date.day.to_ordinal})\n"
      end
    end 
    text_data << "\n<b>Unknown Birthdays</b>\n\n"
    selected.each do |m|
      text_data << m.last_name_first(:short=>true, :initial => true)<<"\n" if m.birth_date.nil? 
    end 
    
    # Create the report of names by birth_date
    start_new_page
    flow_in_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>3, 
      :size=>12, :inline_format => true , :gutter=>5 
    render
  end
end
