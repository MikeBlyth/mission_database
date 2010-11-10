class MembersController < ApplicationController
helper :countries

  active_scaffold :member do |config|
    config.label = "Members"
    list.columns = [:last_name, :first_name, :middle_name, :short_name, :sex,
          :birth_date, :spouse, :country, :status, :contacts, :travels, :terms]
    list.columns.exclude :travel,
                          :bloodtype, :allergies, :medical_facts, :medications
    list.sorting = {:last_name => 'ASC'}
    show.columns = create.columns = update.columns = 
        [:last_name, :first_name, :middle_name, :short_name, :sex,
          :birth_date,  :spouse, :country, 
          :date_active, :status, :family, :family_head,
          :ministry, :ministry_comment, 
          :location, :education, :qualifications,
          :contacts, :terms, :travels,
          :bloodtype, :allergies, :medications
          ]
    config.columns[:country].actions_for_association_links = []
    config.columns[:spouse].actions_for_association_links = [:show]
#    config.delete.link = false
 #   config.columns[:country].form_ui = :select 
    config.columns[:bloodtype].form_ui = :select 
    config.columns[:spouse].form_ui = :select 
    config.columns[:family].form_ui = :select 
 #   config.columns[:family_id].form_ui = :select 
    config.columns[:education].form_ui = :select 
    config.columns[:ministry].form_ui = :select 
    config.columns[:status].form_ui = :select 
    config.columns[:employment_status].form_ui = :select 
    config.columns[:location].form_ui = :select 
    config.columns[:status].inplace_edit = true
    config.columns[:terms].collapsed = true
    config.columns[:travels].collapsed = true
    config.columns[:contacts].collapsed = true
  #  config.columns[:family].actions_for_association_links = []
    config.nested.add_scoped_link(:family) 
 
   config.actions.exclude :search
   config.actions.add :field_search
   config.field_search.human_conditions = true
   config.field_search.columns = [:last_name]#, :location, :birth_date, :bloodtype, :status]
  end


# criteria based on the filter set in application_controller. 
# it would better to somehow have these defined other than hard-coding the numbers, if the 
# users will have access to the table of statuses! Look up the statuses ahead of time and store?
  def conditions_for_collection
    selector = case
    when session[:filter] == 'active'
      ['members.status_id IN (?)', ['2','3','5']]
    when session[:filter] == 'on_field'
      ['members.status_id IN (?)', ['2','3']]
    when session[:filter] == 'home_assignment'
      ['members.status_id IN (?)', ['5']]
    when session[:filter] == 'ha_or_leave'
      ['members.status_id IN (?)', ['5','6']]
    when session[:filter] == 'pipeline'
      ['members.status_id IN (?)', ['12']]
    when session[:filter] == 'other'
      ['members.status_id NOT IN (?)', ['2','3','5','6','12']]
    else
      ['true']
    end
#    logger.error "****** selector = #{selector}"
#    logger.error "****** session[:filter].class = #{session[:filter].class}"
    selector
  end
  
end
