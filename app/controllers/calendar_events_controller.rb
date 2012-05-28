class CalendarEventsController < ApplicationController
  
  before_filter :authenticate 
  include AuthenticationHelper
  load_and_authorize_resource

  before_filter :authenticate #, :only => [:edit, :update]
  
  active_scaffold :calendar_event do |config|
    config.label = "Events for calendar"
    config.columns = [:date, :event]
    config.show.link = false
  #  config.update.link = false
    config.columns[:date].inplace_edit = :true
    config.columns[:event].inplace_edit = :true
  end

  def do_create
  params[:date] = Chronic.parse(params[:date])
    super
  end
  
end

