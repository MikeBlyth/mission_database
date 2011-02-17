class TravelsController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :travel do |config|
  #  config.columns[:member].actions_for_association_links = [:show]
   config.subform.layout = :vertical
   config.columns = [:member, :date, :origin, :destination, :flight, :guesthouse,
     :return_date, :with_spouse, :with_children, :other_travelers, :baggage, :total_passengers, :confirmed]
   config.columns[:member].form_ui = :select 
#   config.columns[:member].options = {:draggable_lists => true}
   config.columns[:member].description = "Person booked for; first create a new member or visitor if necessary."
   config.columns[:baggage].description = "Number of pieces of baggage"
   config.columns[:other_travelers].description = "Names of other travelers (optional)"
   config.columns[:with_spouse].description = "Traveling with spouse?"
   config.columns[:with_children].description = "Traveling with children?"
   config.columns[:total_passengers].description = "Total number of passengers beyond first"
   
    
  end
end 
