module MembersHelper
#  def member_id_form_column(record, options)
#    "Here we are!"
#    collection_select(:record, :state_id, State.find(:all, :order => "name"), :id, :name, {}, options)
#  end
  def spouse_column(record)
    if record.spouse
      record.spouse.first_name
    else
      "-"
    end  
  end

  def spouse_form_column(record,params)
puts "**********RECORD #{record}"
puts "**********PARAMS #{params}"
    result = collection_select('record','spouse', record.possible_spouses, :id, :to_label, 
      { :prompt=> '--select--' }, :class=>'spouse-input', 
      :id=>"record_spouse_#{record.id}")
# ! This logic should go in controller, but we need to find ActiveScaffold callback
# !   in order to place it there.
    if record.spouse_id && record.spouse.spouse_id != record.id
      my_name = record.full_name_short
      spouse_name = record.spouse.full_name_short
      spouse_first_name = record.spouse.first_name
      result << raw("<p class='alert'>Mismatched spouses: #{my_name}" +
                    " shows #{spouse_name} as spouse but #{spouse_first_name} " +
                    " shows ")
      if record.spouse.spouse_id.nil?
        result << raw("no spouse.") 
      else
        result << raw("#{record.spouse.spouse.full_name_short} as spouse.")
      end  
      result << raw("</p><p class='alert'>If you save this record still showing a spouse, " +
            "<em>that</em> person's record will be updated automatically to show #{record.first_name} as " +
            "<em>his</em> or <em>her</em> spouse.</p>")
    end
    return result
  end

  def name_form_column(record,params)
    text_input=text_field_tag 'record[name]', record.name, :id=>params[:id], :class=> "name-input text-input",
      :disabled=>'disabled', :size=>35
    allow_edit = "<a href='#' id='allow_edit_#{params[:id]}' class='allow_edit'>Click to allow editing</a>"
    r = text_input + "\n" + raw(allow_edit)
puts r
    return r
  end

#  def country_form_column(record, params)
#    text_field_tag 'record[country]', record.country_id,  :id=>params[:id], :class=> :country_input
#  end

end
