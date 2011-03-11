class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper  # sign in, sign out, current user, etc.
  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
  end

  @@filter_notices = {
    'all' => "everyone",
    'active' => "active members",
    'field' => "members on field",
    'home_assignment' => "members on home assignment",
    'home_assignment_or_leave' => "members on home assignment or leave",
    'pipeline' => "in pipeline",
    'arrivals' => 'current arrivals',
    'departures' => 'current departures',
    'current' => 'current arrivals and departures',
    'all_dates' => 'all travel including from the past',
    'other' => "other (alumni, retired, deceased, etc.)"
  }

  # Set persistent filter for whether active, on-field, or all members will be shown
  def set_member_filter
    filter = params[:filter] ||= []
    session[:filter] = filter
    flash[:notice] = "Showing #{@@filter_notices[filter]}."
    redirect_to(request.referer)
  end
  
  def set_travel_filter
    filter = params[:travel_filter] ||= []
    session[:travel_filter] = filter
    flash[:notice] = "Showing #{@@filter_notices[filter]}."
    redirect_to(request.referer)
  end
  
end
