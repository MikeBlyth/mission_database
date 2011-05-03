module LocationsHelper
  def primary_work_location_form_column(record, params)
#    result = "<select id='record_primary_work_location' name='record[primary_work_location]' class='primary_work_location-input'>"
    html_params = params.map{|a,b| "#{a.to_s}='#{b.to_s}'"}.join(' ')
    result = "<select #{html_params}>" +
                 location_choices(@record[:primary_work_location_id]) +
             "</select>"
    return raw(result) 
  end
end

