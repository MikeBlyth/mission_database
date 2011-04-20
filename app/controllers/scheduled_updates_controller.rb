class ScheduledUpdatesController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :scheduled_update do |conf|
  end

end 


