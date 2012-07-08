class TravelsController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  include ApplicationHelper
  
  load_and_authorize_resource
  
  active_scaffold :travel do |config|

    config.actions << :config_list

    #  config.columns[:member].actions_for_association_links = [:show]
    config.subform.layout = :vertical
    config.columns = [:traveler_name, :date, :arrival, :origin, :destination, :purpose, :term_passage, :flight, :guesthouse,
      :return_date, :with_spouse, :with_children, :total_passengers]
    show.columns = create.columns = update.columns =  [:member, :date, :time, :arrival, :origin, :destination, :flight, 
      :term_passage, :personal, :ministry_related, :purpose, 
      :own_arrangements, :guesthouse, :driver_accom, 
      :return_date, :return_time, 
      :with_spouse, :with_children, :other_travelers, 
      :baggage, :total_passengers, :confirmed,
      :comments ]
    config.columns[:member].form_ui = :select 
    #   config.columns[:member].options = {:draggable_lists => true}
    config.columns[:member].description = "Person booked for; first create a new member or visitor if necessary."
    config.columns[:member].clear_link
    config.columns[:date].sort_by :sql
    config.columns[:baggage].description = "Number of pieces of baggage"
    config.columns[:other_travelers].description = "Names of other travelers (separate with \";\")"
    config.columns[:with_spouse].description = "Traveling with spouse?"
    config.columns[:with_children].description = "Traveling with children?"
    config.columns[:total_passengers].description = "Total number of passengers"
    config.columns[:total_passengers].label = "Total travelers"
    config.columns[:date].inplace_edit = true
    config.columns[:arrival].inplace_edit = true
    config.columns[:origin].inplace_edit = true
    config.columns[:destination].inplace_edit = true
    config.columns[:purpose].inplace_edit = true
    config.columns[:flight].inplace_edit = true
    config.columns[:guesthouse].inplace_edit = true
    config.columns[:return_date].inplace_edit = false # because editing it doesn't change the actual return flight date
    config.columns[:with_spouse].inplace_edit = true
    config.columns[:with_children].inplace_edit = true
    config.columns[:other_travelers].inplace_edit = true
    config.columns[:baggage].inplace_edit = true
    config.columns[:total_passengers].inplace_edit = true
  #  config.columns[:total_passengers].label = 'Psgrs'
    config.list.label = "Travel schedule"
 #   config.list.pagination = false
    config.columns[:confirmed].inplace_edit = true
    config.list.sorting = { :date => :asc, :id => :asc }

    # Searching
    config.actions.exclude :search
    config.actions.add :field_search
    config.field_search.columns = :date, :member, :other_travelers
#    config.columns[:member].search_sql = 'member.name'
#    config.field_search.columns << :member    
    config.action_links.add 'export', :label => 'Export', :page => true, :type => :collection, 
       :confirm=>'This will download all the travel data (most fields) for ' + 
         'use in your own spreadsheet or database, and may take a minute or two. Is this what you want to do?'
    
  end

  def do_create
    # Are we making travel record for a guest rather than an existing member?
    if params[:guest] || params[:record][:member] == UNSPECIFIED.to_s
      params[:record].delete(:member)
    end  
    members = params[:record][:member]  # Might be array, might be singleton
    if members.class != Array
      members = [members]  # Convert to an array if it's a singleton
    end

    # Now iterate through the array of members and generate the same travel 
    # record for each one
    saved_record_params = params[:record].clone # save parameters since we may alter them
    members.each do |member|
      params[:record][:member] = member   # Set member for each iteration
      super      # Active scaffold creates the record
      # This creates a return trip automatically
      if @record.return_date
        params[:record][:date] = @record.return_date
        params[:record][:time] = @record.return_time
        params[:record][:destination] = @record.origin
        params[:record][:origin] = @record.destination
        params[:record][:arrival] = !@record.arrival
        params[:record][:return_date] = nil
        params[:record][:return_time] = nil
        params[:record][:confirmed] = nil
        params[:record][:guesthouse] = nil
        params[:record][:baggage] = nil
        params[:record][:driver_accom] = nil
        params[:record][:own_arrangements] = false
        params[:record][:comments] = nil
        super # Active scaffold creates the return record
        flash[:notice] = 'Return trip also created'
      end # if @record.return_date, create return trip
      params[:record] = saved_record_params.clone
    end # members.each
#    puts "do_create: @record=#{@record.attributes}"
  end

  # Export CSV file. Exports ALL records, so will have to be modified if a subset is desired
  # No params currently in effect
  def export(params={})
     columns = delimited_string_to_array(Settings.export.travel_fields)
     send_data Travel.export(columns), :filename => "travel.csv"
  end

# Generate a filter string for use in Travel.where(conditions_for_collection)...
  def conditions_for_collection
    selector = case session[:travel_filter]
    when  'arrivals'   then ['travels.arrival AND travels.date >= (?)', Date::today]
    when  'departures' then ['travels.arrival = ? AND travels.date >= (?)', false, Date::today]
      when  'all_dates'  then TRUE
      when  'current'    then ['travels.date >= (?)', Date::today]
      else ['travels.date >= (?)', Date::today] # This will include nil case where filter has not been set for session
    end
    return selector
  end
 
  def do_new
    @new = true  # pass to the form, because an existing travel record only has a single
                     # member, so we can't use multiple select
    super
  end

  def before_update_save(record)
    # This is just to save a changed member_id, because I cannot figure out why AS won't save
    # it as part of the normal update!
    # Note that when a travel record is _updated_, it can only have a single member_id.
    # Also, once a record has a member_id, it can't be changed. So the only time this method
    # will be used is when updating a record that has an "other traveler" but no member.
    return unless params[:member_id]
    member = params[:record][:member_id]
    record.member_id = member.to_i if member
  end
end 
