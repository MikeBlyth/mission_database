require 'reports_helper'

class WhereIsTable_2 < Prawn::Document
  include ReportsHelper
  include ApplicationHelper

  def family_data_line(f)
    head = f.head
    wife = f.wife
    name = head.last_name_first(:short=>true, :middle=>false)
    name << " & #{wife.short}" if f.wife
    name << ' ('+f.status.description+')' if f.status.code != 'field'
    kids = f.children_names
    name << "\n#{NBSP}#{NBSP}<i>#{smart_join(kids)}</i>" unless kids.empty?
    contact_head = head.contacts.where(:contact_type_id=>@field_contact_id).first
    if contact_head   # If there is a valid contact for family head
      phone = format_phone(contact_head.phone_1) || '---'
      email = contact_head.email_1 || '---'
      if wife # if there IS a wife
        contact_wife = wife.contacts.where(:contact_type_id=>@field_contact_id).first
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
    return [ name, email, phone ]
  end

  def to_pdf(families,options = {})
    location_col = default_true(options[:location_column]) # make separate column for locations? Default=true
    @field_contact_id = ContactType.find_by_code(1).id  # Use this to select the right contact for field

    # Part 1 -- Sorted by location
    page_header(:title=>"Where Is Everyone?", :left=>'by location')#, :left => comments)
    families_by_location = families.sort do |x,y| 
      (description_or_blank(x.residence_location,'') + x[:name]) <=> 
      (description_or_blank(y.residence_location,'') +y[:name])
    end
    if location_col
      table_data = [['Location','Name', 'Email', 'Phone']]
    else
      table_data = [['Name', 'Email', 'Phone']]
    end
      
    location = ''
    families_by_location.each do |f|
      # Check for new residence location so we can group
      if location != description_or_blank(f.residence_location)
        location = description_or_blank(f.residence_location)
        displayed_location = location
        location = '??' if location.blank?
        unless location_col  # Give new location its own row if it does not have its own column
          table_data << ["<b>#{location}</b>", '', ''] # Need enough columns to fill the row, or borders won't be right
        end  
      else
        displayed_location = ''  # not a new location, so don't show it in the location column (but what about top of page!?)
      end
      if location_col
        table_data << [displayed_location] + family_data_line(f)
      else
        table_data << family_data_line(f)
      end
    end

    bounding_box [0, cursor-20], :width => bounds.right-bounds.left, :height=> (cursor-20)-bounds.bottom-20 do
      table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true}) do 
        row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
      end

      # Part 2 -- Sorted by family
      table_data = [['<i>Name</i>', 'Email', 'Phone']]
      families.each do |f|
        table_data << family_data_line(f)
      end      
      start_new_page
      table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true}) do 
        row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
      end
 

    end # bounding_box


    render
  end
end
