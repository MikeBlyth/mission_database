require 'reports_helper'

class WhereIsTable < Prawn::Document
include ReportsHelper

  def to_pdf(by_name,by_location,comments=nil)
    table_data = [['Name', 'Location']]
    by_name.each do |m|
      table_data << [ m[:name], m[:current_location] ]
    end
   page_header(:title=>"Where Is Everyone?")#, :left => comments)

#    bounding_box([0,bounds.top-60], :width=>bounds.width) do

        table(table_data, :header => true, 
                          :row_colors => ["F0F0F0", "FFFFCC"],
                          :cell_style => { :size => 10}) do 
          row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
        end
#    end
    render
  end
end
