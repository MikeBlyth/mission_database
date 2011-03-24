#require 'prawn_extend'
require 'reports_helper'

# Prawn document to generate PDF for blood types
class WhereisReport < Prawn::Document
include ReportsHelper

  def fix_missing_locations(member)
    if member.residence_location_id.nil? || member.residence_location.nil?
      member.residence_location_id = UNSPECIFIED    
    end  
    if member.work_location_id.nil? || member.work_location.nil?
      member.work_location_id = UNSPECIFIED    
    end  
  end

  def to_pdf(selected,comments="")
     # selected is an array of Members (with only some columns defined)
     # first, sort the array by name
    selected.sort! {|x,y| x[:name] <=> y[:name]}
    text_data = ''
    selected.each do |m|
#puts "Member #{m.last_name_first}, residence=#{m.residence_location} (#{m.residence_location_id})"
      text_data << "#{m[:name]}: <i>#{m[:location]}</i>\n\n"
    end
    
    page_header(:title=>'Where Is Everyone', :left=>'SIM Nigeria Reports')
    move_down 8
    flow_in_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>3, 
      :size=>10,  :gutter=>5 , :inline_format => true

    # Now sort by location 
    selected.sort! {|x,y| (x[:location]) <=> (y[:location])}
    text_data = ''
    location = ''
    selected.each do |m|
      if location != m[:location]
        location = m[:location]
        text_data << "\n #{location}\n\n"
      end
      text_data << m[:name] << "\n"
    end
    # Create the report of names by location
    start_new_page
    flow_in_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>3, 
      :size=>10, :inline_format => true , :gutter=>5 
    render
  end
end
