class FieldTermsController < ApplicationController

  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  include ApplicationHelper
  
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
    config.actions.exclude :search, :show
    config.update.link = false
#    config.create.link = false
    config.actions.add :field_search
    config.field_search.columns = :member, :start_date, :end_date, :ministry, :primary_work_location, :employment_status

    config.action_links.add 'export', :label => 'Export', :page => true, :type => :collection, 
       :confirm=>'This will download all the field_term data (most fields) for ' + 
         'use in your own spreadsheet or database, and may take a minute or two. Is this what you want to do?'
  end

  # Export CSV file. Exports ALL records, so will have to be modified if a subset is desired
  # No params currently in effect
  def export(params={})
     columns = delimited_string_to_array(Settings.export.field_term_fields)
     columns = ['member'] if columns.empty?  # to prevent any bad behavior with empty criteria
     send_data FieldTerm.export(columns), :filename => "field_terms.csv"
  end


end 

