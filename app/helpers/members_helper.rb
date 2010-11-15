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
