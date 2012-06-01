class FieldTermsController < ApplicationController

  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :field_term do |config|
    config.columns = [:member, :start_date, :start_estimated, :end_date, :end_estimated, :ministry, :primary_work_location, :employment_status]
 #  config.subform.layout = :vertical
#    config.columns[:start_date].form_ui = :select 
    config.columns[:start_date].inplace_edit = true
    config.columns[:end_date].inplace_edit = true
    config.columns[:start_estimated].inplace_edit = true
    config.columns[:start_estimated].label = "Est?"
    config.columns[:end_estimated].inplace_edit = true
    config.columns[:end_estimated].label = "Est?"
    config.columns[:ministry].form_ui = :select 
    config.columns[:ministry].inplace_edit = true
#    config.columns[:primary_work_location].form_ui = :select 
    config.columns[:primary_work_location].inplace_edit = true
    config.columns[:employment_status].form_ui = :select 
    config.columns[:employment_status].inplace_edit = true

    # Searching
    config.actions.exclude :search
    config.actions.add :field_search
    config.field_search.columns = :member, :start_date, :end_date, :ministry, :primary_work_location, :employment_status
  end

end 

