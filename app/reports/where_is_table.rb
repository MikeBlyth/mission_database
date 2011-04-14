require 'reports_helper'

class WhereIsTable < Prawn::Document
include ReportsHelper

  def to_pdf(by_name,by_location,comments=nil)
    table_data = [['Name', 'Location']]
    by_name.each do |m|
      table_data << [ m[:name], m[:current_location] ]
    end
    page_header(:title=>"Where Is Everyone?")#, :left => comments)

    table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true}) do 
      row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
    end
    start_new_page
move_down 40
    table_data = [['<i>Name</i>', 'Email', 'Phone']]
    location = ''
    by_location.each do |m|
      if location != m[:residence_location]
        location = m[:residence_location]
#        table_data << [] unless table_data.length == 1
        table_data << ["<b>#{location}</b>", '']
      end
      name = m[:name]
      name += "& #{m[:spouse].short}" if m[:spouse]
      table_data << [ name, m[:email], m[:phone] ]
    end

    table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true}) do 
      row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
    end


    render
  end
end
