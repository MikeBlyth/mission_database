class FieldTermsController < ApplicationController

  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :field_term do |config|
   config.columns = [:start_date, :end_date, :ministry, :location, :employment_status,
        :est_start_date, :est_end_date]
 #  config.subform.layout = :vertical
  end

end 

