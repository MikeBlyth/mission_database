module TravelsHelper
  
  def traveler_name_column(record)
    if record.member
      link_to record.traveler_name, member_path(record.member_id)
    else  
      record.traveler_name 
    end  
  end

  def time_form_column(record, params)
    result = "<input id='record_time_#{record.id}' class='time-input text-input' type='text'" + 
      "name='record[time]' " + 
      "value='#{record.time.strftime("%l:%M %P") if record.time}' include_blank='true' autocomplete='off'>"
  end

  def time_column(record)
    result = record.time.strftime("%l:%M %P") if record.time
  end
  
  def return_time_form_column(record, params)
    result = "<input id='record_return_time_#{record.id}' class='return-time-input text-input' type='text'" + 
      "name='record[return_time]' " + 
      "value='#{record.return_time.strftime("%l:%M %P") if record.return_time}' include_blank='true' autocomplete='off'>"
  end
  
  def return_time_column(record)
    result = record.return_time.strftime("%l:%M %P") if record.return_time
  end
  
end

