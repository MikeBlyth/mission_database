class PersonnelDataController < ApplicationController

  load_and_authorize_resource

  active_scaffold :personnel_data do |config|
    config.label = "Personnel Information"
    config.actions = :list, :search
    config.columns = [:member, :education, :qualifications, :employment_status, :date_active, :comments, :est_end_of_service]
    config.columns[:employment_status].form_ui = :select 
    config.columns[:employment_status].inplace_edit = true
#    config.subform.layout = :vertical
 end

end
