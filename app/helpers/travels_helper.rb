module TravelsHelper
  def member_column(record)
    result = record.member.full_name_short
    if record.with_spouse
      if record.member.spouse && # There is a spouse listed in the database
         Settings.travel.include_spouse_name_in_list  # the setting is on
        result = "#{record.member.short} & #{record.member.spouse.short} #{record.member.last_name}" 
      else
        result = "M/M " + result 
      end
    end
    return raw(result) 
  end
end

