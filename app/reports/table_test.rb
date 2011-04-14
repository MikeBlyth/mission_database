require 'reports_helper'

class TableTest < Prawn::Document
include ReportsHelper

  def to_pdf(selected,comments)
     table_data = [['Last name', 'First name', 'Status']]
    selected.each do |m|
      table_data << [m.last_name, m.first_name, m.status.description]
    end
    page_header(:title=>"Statuses")

    bounding_box([0,bounds.top-60], :width=>bounds.width) do
        text comments, :size => 10
        move_down 20
        table(table_data, :header => true) do |t|
  #        t.row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
        end
        start_new_page
        text "That's all folks!"
    end
    render
  end
end
