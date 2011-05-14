class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper  # sign in, sign out, current user, etc.

  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
  end

  before_filter :require_https #, :only => [:login, :signup, :change_password] 

  def require_https
    redirect_to :protocol => "https://" unless (request.protocol=='https://' or request.host=='localhost' or
        request.host == 'test.host' or request.remote_addr == '127.0.0.1')
  end

  rescue_from CanCan::AccessDenied do |exception|
# puts "CanCan AccessDenied #{exception.message}"
    if !signed_in? 
      redirect_to signin_path
    else  
      redirect_to request.referer, :alert => exception.message
    end
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
    if request.referer =~ /members/
      redirect_to members_path 
    elsif request.referer =~ /famil/
      redirect_to families_path
    else 
      redirect_to(root_path)
    end  
  end
  
  def set_travel_filter
    filter = params[:travel_filter] ||= []
    session[:travel_filter] = filter
    flash[:notice] = "Showing #{@@filter_notices[filter]}."
    redirect_to(travels_path)
  end

  
  
end
