class TravelsController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper

  load_and_authorize_resource
  
  active_scaffold :travel do |config|
    #  config.columns[:member].actions_for_association_links = [:show]
    config.subform.layout = :vertical
    config.columns = [:member, :date, :arrival, :origin, :destination, :purpose, :flight, :guesthouse,
     :return_date, :with_spouse, :with_children, :other_travelers, :baggage, :total_passengers, :confirmed]
    config.columns[:member].form_ui = :select 
    #   config.columns[:member].options = {:draggable_lists => true}
    config.columns[:member].description = "Person booked for; first create a new member or visitor if necessary."
    config.columns[:date].sort_by :sql
    config.columns[:baggage].description = "Number of pieces of baggage"
    config.columns[:other_travelers].description = "Names of other travelers (optional)"
    config.columns[:with_spouse].description = "Traveling with spouse?"
    config.columns[:with_children].description = "Traveling with children?"
    config.columns[:total_passengers].description = "Total number of passengers beyond first"
    config.columns[:date].inplace_edit = true
    config.columns[:arrival].inplace_edit = true
    config.columns[:origin].inplace_edit = true
    config.columns[:destination].inplace_edit = true
    config.columns[:purpose].inplace_edit = true
    config.columns[:flight].inplace_edit = true
    config.columns[:guesthouse].inplace_edit = true
    config.columns[:return_date].inplace_edit = true
    config.columns[:with_spouse].inplace_edit = true
    config.columns[:with_children].inplace_edit = true
    config.columns[:other_travelers].inplace_edit = true
    config.columns[:baggage].inplace_edit = true
    config.columns[:total_passengers].inplace_edit = true
    config.columns[:confirmed].inplace_edit = true
    config.list.sorting = { :date => :asc }
  end

  def do_create
    super
    # This creates a return trip automatically
    if @record.return_date
      params[:record][:date] = @record.return_date
      params[:record][:destination] = @record.origin
      params[:record][:origin] = @record.destination
      params[:record][:return_date] = nil
      params[:record][:arrival] = !@record.arrival
      params[:record][:confirmed] = nil
      super
      flash[:notice] = 'Return trip also created'
    end
#    puts "do_create: @record=#{@record.attributes}"
  end

# Generate a filter string for use in Travel.where(conditions_for_collection)...
  def conditions_for_collection
    selector = case session[:travel_filter]
      when  'arrivals'   then ['travels.arrival = TRUE AND travels.date >= (?)', Date::today]
      when  'departures' then ['travels.arrival = FALSE AND travels.date >= (?)', Date::today]
      when  'all_dates'  then TRUE
      when  'current'    then ['travels.date >= (?)', Date::today]
      else ['travels.date >= (?)', Date::today] # This will include nil case where filter has not been set for session
    end
    return selector
  end
  
end 
