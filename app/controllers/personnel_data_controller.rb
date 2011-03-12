class PersonnelDataController < ApplicationController

  load_and_authorize_resource

  active_scaffold :personnel_data do |config|
    config.label = "Personnel Information"
    config.columns = [:member, :education, :qualifications, :employment_status, :date_active, :comments]
  end

end
