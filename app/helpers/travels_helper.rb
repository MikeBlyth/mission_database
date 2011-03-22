module TravelsHelper
  
  def traveler_name(record)
    record.traveler.full_name_short 
  end
  
  def member_column(record)
    if record.class == Travel
      result = traveler_name(record)
puts "member_column travel result = #{result}"
    else
      # set 'member' to be either the record itself, if it responds to name methods, or
      # to the member to which this record belongs ('member = record.member')
      if record.respond_to?(:full_name_short)
        member = record 
      else
        member = record.member
        return '' unless member.respond_to?(:full_name_short)
      end
      result = member.last_name_first(:initial=>true)
    end    

    # Now add spouse's name, or 'M/M', if the record has with_spouse
    if record.respond_to?(:with_spouse) && record.with_spouse
      if record.member && record.member.spouse && # There is a spouse listed in the database
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

