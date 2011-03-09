module FieldTermsHelper
  def primary_work_location_form_column(record, params)
#puts "**** PWL #{@record[:primary_work_location_id]}, #{@record.attributes}, record--#{record[:primary_work_location_id]}, #{record.attributes}"
    result = "<select id='record_primary_work_location' name='record[primary_work_location]' class='primary_work_location-input'>"
    result << location_choices(@record[:primary_work_location_id])
    result << "</select>"
    return raw(result) 
  end
end

