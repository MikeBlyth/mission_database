class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
  end

  @@filter_notices = {
    'all' => "everyone",
    'active' => "active members",
    'on_field' => "on field",
    'home_assignment' => "on home assignment",
    'ha_or_leave' => "on home assignment or leave",
    'pipeline' => "in pipeline",
    'other' => "other (alumni, retired, deceased, etc.)"
  }

  # Set persistent filter for whether active, on-field, or all members will be shown
  def set_member_filter
    filter = params[:filter] ||= []
    session[:filter] = filter
    flash[:notice] = "Filter changed: now showing #{@@filter_notices[filter]}."
      
    redirect_to(request.referer)
  end
  
end
