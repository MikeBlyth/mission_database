class EmploymentStatusesController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :employment_status do |config|
    config.columns = [:code, :description, :org_member, :umbrella, :current_use]
    config.show.link = false
    config.columns[:description].inplace_edit = true
    config.columns[:org_member].inplace_edit = true
    config.columns[:umbrella].inplace_edit = true
    config.columns[:current_use].inplace_edit = true
    list.sorting = {:code => 'ASC'}
  end
end 


