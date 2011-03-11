class HealthDataController < ApplicationController

  active_scaffold :health_data do |config|
    config.label = "Health Information"
    config.columns = [:member, :current_meds, :issues, :bloodtype]
    
  end
end
