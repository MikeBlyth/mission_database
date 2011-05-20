require 'reports_helper'

# Prawn document to generate Field Terms report
class ListFieldTerms < Prawn::Document
include ReportsHelper

  def to_pdf(members)
     # selected is an array of Members info (with only some columns defined)
     #   and is already sorted by name
    table_data = [['Name', 'Current/Latest', 'Home Assignment', 'Next Term']]
    members.each do |m|
      next_ha = m.next_home_assignment
      name = m.last_name_first(:initial=>true)
      current = m.most_recent_term.dates if m.most_recent_term
      home_assignment = "#{next_ha[:start] || '?'}--#{next_ha[:end] || '?'} #{next_ha[:end_estimated]}"
      pending = m.pending_term.dates if m.pending_term
      table_data << [name, current, home_assignment, pending]
    end    
    page_header(:title=>"Current and Projected Field Terms", :left=>'SIM Nigeria Reports')
    bounding_box [0, cursor-20], :width => bounds.right-bounds.left, :height=> (cursor-20)-bounds.bottom-20 do

      table(table_data, :header => true, 
                    :row_colors => ["FFFFFF", "F8F8F8"],
                    :cell_style => { :size => 10, :inline_format => true}) do 
        row(0).style :background_color => 'F0F0F0'
      end
      move_down 10
      footnote = "\"(Est)\" means that the end of home assignment has been estimated using the SIM formula. This may or may not be what the member has planned."    
      group {text footnote, :size=>9, :inline_format=>true} 
    end
    render
  end
end
