# require 'prawn_extend'
require 'reports_helper'

# Prawn document to generate PDF for blood types
class PhoneEmailReport < Prawn::Document
include ReportsHelper
    def to_pdf(selected,params={})
    
     # selected is an array of Members (with only some columns defined)
     # first, sort the array by name
     selected.sort! {|x,y| x.last_name_first <=> y.last_name_first}
  #   table_data = [['Last name', 'First name', 'Blood type']]
    text_data = ''
    title = params[:title] || "Phone"
    left_head = params[:left_head] || "SIM Nigeria Reports"
    comments = params[:comments] || ''
    selected.each do |member|
      text_data << "#{member.last_name_first(:short=>true, :middle=>false)}:  " 
      field_contact = member.contacts.find_by_contact_type_id(1)
      if field_contact
        text_data << [field_contact.phone_1, field_contact.phone_2, field_contact.email_1, field_contact.email_2].join(', ')
        
      end
    text_data << "\n\n"
    end
    
    page_header(:title=>title, :left=>left_head)
    move_down 8
    flow_in_columns text_data, :top_margin=>50, :bottom_margin=>50, :columns=>2, 
      :size=>12, :inline_format => true , :gutter=>15 
    render
  end
end
