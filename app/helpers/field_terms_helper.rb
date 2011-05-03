module FieldTermsHelper

  def primary_work_location_form_column(record, params)
#puts "**** PWL #{@record[:primary_work_location_id]}, #{@record.attributes}, record--#{record[:primary_work_location_id]}, #{record.attributes}"
    html_params = params.map{|a,b| "#{a.to_s}='#{b.to_s}'"}.join(' ')
    result = "<select #{html_params}>" +
                 location_choices(@record[:primary_work_location_id]) +
             "</select>"
    return raw(result) 
  end
end

