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

  def to_pdf(selected, by_location, comments="")
     # selected is an array of Members info (with only some columns defined)
     #   and is already sorted by name
    text_data = ''
    selected.each do |m|
#puts "Member #{m.last_name_first}, residence=#{m.residence_location} (#{m.residence_location_id})"
      text_data << "#{m[:name]}: <i>#{m[:current_location]}</i>\n\n"
    end
    
    page_header(:title=>'Where Is Everyone?', :left=>'SIM Nigeria Reports')
    move_down 8
    flow_in_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>3, 
      :size=>10,  :gutter=>5 , :inline_format => true

    # Now by location 
    text_data = ''
    location = ''
    by_location.each do |m|
      if location != m[:residence_location]
        location = m[:residence_location]
        text_data << "\n" unless text_data.blank?
        text_data << "<b>#{location}</b>\n\n"
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
