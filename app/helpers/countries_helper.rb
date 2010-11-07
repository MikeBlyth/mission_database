module CountriesHelper

  def name_column(record)
    record.name.force_encoding('utf-8')
  end

# Subform overrides -- for now, they just force encoding to bypass bug in mysql connector
 # def country_id_form_column(record, options)
 #   collection_select(:record, :country_id, Country.choices, :id, :name, 
 #        options ={:prompt => "-Select country"})  
 #    #    (text_field :record, :name, options.merge(:size=>20))
 # end

 # def id_form_column(record, options)
 #    text_field :record, :nationality, options.merge(:size=>20)
#    collection_select(:record, :state_id, State.find(:all, :order => "name"), :id, :name, {}, options)
 # end
end
