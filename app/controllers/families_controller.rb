class FamiliesController < ApplicationController
  active_scaffold :family do |config|
     list.sorting = {:name => 'ASC'}
#config.action_links.add "new", :label => 'Spouse', :controller=> :members, :parameters=>{:spouse=>'spouse', },
#    :type => :member
#config.action_links.add "new", :label => 'Add Child', :controller=> :members, :parameters=>{:child=>'child'},
#    :type => :member
    config.columns = [:name, :sim_id, :members, :location, :status]
    update.columns.exclude :members 
    create.columns.exclude :members
    config.columns[:status].clear_link  # Do not include link to family head in the list view
    config.columns[:location].clear_link  # Do not include link to family head in the list view
#    config.update.link = false  # Do not include a link to "Edit" on each line
#    config.delete.link = false  # Do not include a link to "Delete" on each line
    config.columns[:members].associated_limit = nil    # show all members, no limit to how many
    config.columns[:location].form_ui = :select 
    config.columns[:status].form_ui = :select

  end
  
  def conditions_for_collection
    selector = case
    when session[:filter] == 'active'
      ['families.status_id IN (?)', ['2','3','5']]
    when session[:filter] == 'on_field'
      ['families.status_id IN (?)', ['2','3']]
    when session[:filter] == 'home_assignment'
      ['families.status_id IN (?)', ['5']]
    when session[:filter] == 'ha_or_leave'
      ['families.status_id IN (?)', ['5','6']]
    when session[:filter] == 'pipeline'
      ['families.status_id IN (?)', ['12']]
    when session[:filter] == 'other'
      ['families.status_id NOT IN (?)', ['2','3','5','6','12']]
    else
 #     ['?', true]
      ['families.id > 0']
    end

    selector
  end  
  
end

