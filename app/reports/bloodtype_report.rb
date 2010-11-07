#require 'prawn_extend'
require 'reports_helper'

# Prawn document to generate PDF for blood types
class BloodtypeReport < Prawn::Document
include ReportsHelper

  def to_pdf(selected,comments)
     # selected is an array of Members (with only some columns defined)
     # first, sort the array by name
     selected.sort! {|x,y| x.last_name_first <=> y.last_name_first}
  #   table_data = [['Last name', 'First name', 'Blood type']]
    text_data = ''
    selected.each do |m|
      text_data << "#{m.last_name}, #{m.first_name}: <i>#{m.bloodtype.full}</i>\n\n"
    end
    page_header(:title=>'Blood Types', :left=>'SIM Nigeria Reports')
    move_down 8
    formatted_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>3, 
      :size=>10,  :gutter=>5 , :inline_format => true
    # Now sort by bloodtype 
    selected.sort! {|x,y| (x.bloodtype.full+x.last_name_first) <=> (y.bloodtype.full+y.last_name_first)}
    text_data = ''
    current_blood_type = ''
    selected.each do |m|
      if current_blood_type != m.bloodtype.full
        current_blood_type = m.bloodtype.full
        text_data << "\n-- Type #{current_blood_type} --\n\n"
      end
      text_data << m.last_name_first(:initial => true) << "\n"
    end
    # Create the report of names by bloodtype
    start_new_page
    formatted_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>3, 
      :size=>10, :inline_format => true , :gutter=>5 
    render
  end
end
