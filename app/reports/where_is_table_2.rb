require 'reports_helper'

class WhereIsTable_2 < Prawn::Document
  include ReportsHelper
  include ApplicationHelper

  def to_pdf(families,comments=nil)
    page_header(:title=>"Where Is Everyone?")#, :left => comments)
#    table_data = [['Name', 'Location']]
#    by_name.each do |m|
#      table_data << [ m[:name], m[:current_location] ]
#    end

#    table(table_data, :header => true, 
#                      :row_colors => ["F0F0F0", "FFFFCC"],
#                      :cell_style => { :size => 10, :inline_format => true}) do 
#      row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
#    end
#    start_new_page
    families_by_location = families.sort do |x,y| 
      (description_or_blank(x.residence_location,'') + x[:name]) <=> 
      (description_or_blank(y.residence_location,'') +y[:name])
    end
    table_data = [['<i>Name</i>', 'Email', 'Phone']]
    field_contact_id = ContactType.find_by_code(1).id  # Use this to select the right contact for field
    location = ''
    families_by_location.each do |f|
      # Check for new residence location so we can group
      if location != description_or_blank(f.residence_location)
        location = description_or_blank(f.residence_location)
        table_data << ["<b>#{location}</b>", '', ''] # Need enough columns to fill the row, or borders won't be right
      end
      head = f.head
      wife = f.wife
      name = head.last_name_first(:short=>true, :middle=>false)
      name << " & #{wife.short}" if f.wife
      kids = f.children_names
      name << "\n#{NBSP}#{NBSP}<i>#{smart_join(kids)}</i>" unless kids.empty?
      contact_head = head.contacts.where(:contact_type_id=>field_contact_id).first
      if contact_head   # If there is a valid contact for family head
        phone = format_phone(contact_head.phone_1) || '---'
        email = contact_head.email_1 || '---'
        if wife # if there IS a wife
          contact_wife = wife.contacts.where(:contact_type_id=>field_contact_id).first
          if contact_wife # if wife has a valid contact record
            phone += "\n#{format_phone(contact_wife.phone_1)}" if contact_wife.phone_1 &&
                contact_wife.phone_1 != contact_head.phone_1
            email += "\n#{contact_wife.email_1}" if contact_wife.email_1 &&
                contact_wife.email_1 != contact_head.email_1
          end
        end
        # Add a second phone & email if they exist and only one has been used already
        phone += "\n#{format_phone(contact_head.phone_2)}" if contact_head.phone_2 && !(phone =~ /\n/) 
        email += "\n#{contact_head.email_2}" if contact_head.email_2 && !(email =~ /\n/) 
      end # if contact_head          
      table_data << [ name, email, phone ]
    end

    bounding_box [0, cursor-20], :width => bounds.right-bounds.left, :height=> (cursor-20)-bounds.bottom-20 do
      table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true}) do 
        row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
      end
    end # bounding_box


    render
  end
end
