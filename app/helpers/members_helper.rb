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

  def country_form_column(record, params)
logger.error "********Country input: params=#{params}, record=#{record}"
    text_field_tag 'record[country]', record.country_id,  :id=>params[:id], :class=> :country_input
  end
end
