class EmploymentStatusesController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :employment_status do |config|
    config.columns = [:code, :description]
    config.show.link = false
    config.columns[:description].inplace_edit = true
    list.sorting = {:code => 'ASC'}
  end
end 


