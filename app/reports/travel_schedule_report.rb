# require 'prawn_extend'
require 'reports_helper'

# Prawn document to generate PDF for travel schedule
class TravelScheduleReport < Prawn::Document
include ReportsHelper
    def to_pdf(selected,params={})
    
     # selected is an array of Members (with only some columns defined)
     # first, sort the array by name
    last_date = nil
    title = params[:title] || "Travel Schedule"
    left_head = params[:left_head] || "#{Date.today}"
    comments = params[:comments] || ''
    text_data = ''
    selected.each do |travel|
      # Need to print date if it is not the same as the last date
      member = travel.member
      if travel.date != last_date
        last_date = travel.date
        text_data << "#{travel.date}\n"
      end  
      # Name part example: John{ & Linda} Jackson{ w kids}:
      text_data << "#{member.short}"
      spouse_name = member.spouse ? member.spouse.short : "spouse" # Use name if spouse is listed in the database, else "spouse"
      text_data << " & #{spouse_name}"  if travel.with_spouse
      text_data << " #{travel.member.last_name}" 
      text_data << " w kids" if travel.with_children 
      text_data << ": "
#      if !Settings.travel.airports_local.include?(travel.origin)
      if travel.arrival?
        text_data << "Arr #{travel.destination} from #{travel.origin}"
      else
        text_data << "Dep #{travel.origin} to #{travel.destination}"
      end 
      text_data << " on #{travel.flight}" if travel.flight
      text_data << " with #{travel.other_travelers}" if travel.other_travelers
      text_data << ", #{travel.total_passengers} total" if travel.total_passengers > 1
      text_data << ", #{travel.baggage} pcs" if travel.baggage
      text_data << "; #{travel.guesthouse} GH" if travel.guesthouse && travel.guesthouse != 'Unspecified'
      text_data << (travel.confirmed.nil? ? "; **unconfirmed**" : "; confirmed")
      text_data << ".\n\n"
    end # each travel record
    
    page_header(:title=>title, :left=>left_head)
    move_down 8
    flow_in_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>2, 
      :size=>12, :inline_format => true , :gutter=>15 
    render
  end
end
