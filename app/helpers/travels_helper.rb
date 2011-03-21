module TravelsHelper
  def member_column(record)
    if record.respond_to?(:full_name_short)
      member = record 
    else
      member = record.member
      return '' unless member.respond_to?(:full_name_short)
    end    
    result = record.class == Travel ? member.full_name_short : member.last_name_first(:initial=>true)
    if record.respond_to?(:with_spouse) && record.with_spouse
      if record.member.spouse && # There is a spouse listed in the database
         Settings.travel.include_spouse_name_in_list  # the setting is on
        result = "#{record.member.short} & #{record.member.spouse.short} #{record.member.last_name}" 
      else
        result = "M/M " + result 
      end
    end
    return raw(result) 
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

