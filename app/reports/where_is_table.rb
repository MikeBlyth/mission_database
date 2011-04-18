require 'reports_helper'

class WhereIsTable < Prawn::Document
  include ReportsHelper
  include ApplicationHelper
  include FamiliesHelper
    
  # Return the data to be inserted into table from family f
  def family_data_line(f)
    formatted = family_data_formatted(f)
    name_column = formatted[:couple] + 
                  (f.status.code == 'field' ? '' : " (#{f.status.description})") +
                  (formatted[:children].blank? ? '' : "\n<i>#{formatted[:children]}</i>" ) 
    return [ name_column, formatted[:email], formatted[:phone] ]
  end

  def to_pdf(families,options = {})
    location_col = default_true(options[:location_column]) # make separate column for locations? Default=true

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
        location = '??' if location.blank?
        displayed_location = location
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
