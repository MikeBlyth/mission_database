# require 'prawn_extend'
require 'reports_helper'

# Prawn document to generate PDF for travel schedule
class TravelScheduleTable < Prawn::Document
  include ReportsHelper
  include ApplicationHelper

  def to_pdf(selected,params={})

puts "#{params}"  
    font_size = params[:font_size] || 10
    font_size += -1 if params[:detail_columns] && params[:residence_column]

    # Generate the data for the table
    table_data = [header_row(params)]
    selected.each do |travel|
      table_data << data_row(travel, params)
    end # each travel record
    
    # Compose the page 
    title = params[:title] || "Travel Schedule"
    left_head = params[:left_head] || "#{Date.today}"
    page_header(:title=>title, :left=>left_head)
    bounding_box [0, cursor-20], :width => bounds.right-bounds.left, 
       :height=> (cursor-20)-bounds.bottom-20 do
      table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => font_size, :inline_format => true}) do 
        row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
      end # table ... do
    end # bounding_box
    render
  end # to_pdf
private

  # Generate a table row from a given travel record
  def data_row(travel, params)
    names = travel.travelers
    names << ". (#{travel.total_passengers} total)" if travel.total_passengers > 2
    arrdep = travel.arrival? ? 'A' : 'D'
    sim_or_personal = 'S' if travel.term_passage
    sim_or_personal = 'P' if travel.personal
    flight = "#{travel.flight} #{travel.time.strftime('%l:%M %P') if travel.time}"
    own_arrangements = travel.own_arrangements ? "Will make own arrangements. " : ''
    row = [travel.date.strftime('%e %b'), arrdep, flight, names]
    if params[:residence_column]
      row << (travel.member ? "#{travel.member.residence_location}" : '')
    end
    if params[:detail_columns]
      row << travel.baggage 
      row << smart_join([travel.guesthouse || '---', travel.driver_accom],"\n") 
      row << sim_or_personal      
    end              
    row << own_arrangements + (travel.comments || '')
    return row
  end # data_row

  def header_row(params)
    row = ['Date','Arr', 'Flt', 'Name(s)']
    row << 'Residence' if params[:residence_column]
    row << 'Box' << 'Accom/ Driver Accom' << 'SIM/ Pers' if params[:detail_columns]
    row << 'Comments'
    return row
  end # header_row

end # Class
