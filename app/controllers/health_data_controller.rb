class HealthDataController < ApplicationController

  load_and_authorize_resource

  active_scaffold :health_data do |config|
    config.label = "Health Information"
    config.columns = [:member, :current_meds, :issues, :allergies, :bloodtype]
    config.columns[:bloodtype].form_ui = :select 
    config.subform.layout = :vertical
    
  end
end
