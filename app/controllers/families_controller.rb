class FamiliesController < ApplicationController
  helper :name_column
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :family do |config|
     list.sorting = {:name => 'ASC'}
#config.action_links.add "new", :label => 'Spouse', :controller=> :members, :parameters=>{:spouse=>'spouse', },
#    :type => :member
#config.action_links.add "new", :label => 'Add Child', :controller=> :members, :parameters=>{:child=>'child'},
#    :type => :member
    config.columns = [:name, :name_override, :first_name, :last_name, :middle_name, :sim_id, :members, :location, :status]
    update.columns.exclude :members 
    update.columns.exclude :members, :first_name, :last_name, :middle_name 
    create.columns.exclude :members
    list.columns.exclude  :name_override
    config.columns[:status].clear_link  # Do not include link to family head in the list view
    config.columns[:location].clear_link  # Do not include link to family head in the list view
#    config.update.link = false  # Do not include a link to "Edit" on each line
#    config.delete.link = false  # Do not include a link to "Delete" on each line
    config.columns[:members].associated_limit = nil    # show all members, no limit to how many
    config.columns[:location].form_ui = :select 
    config.columns[:status].form_ui = :select
    config.columns[:name].description = "This is the name by which the family will be known"
    config.columns[:first_name].description = "of individual or head of family"
  
    config.columns[:sim_id].label = "SIM ID Number"
    config.create.link.page = true 

  end
  
  def add_family_member
    record = Member.new(:last_name=>'NewMember', :first_name=>'Guess')
    params[:record] = {:last_name=>'NewMember', :first_name=>'Guess'}
    redirect_to new_member_path
  end

  def edit_inline
    
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

  def do_new
    super
#    @unspecified_location = Location.find_by_description('Unspecified')
# TODO Need to standardize -- status should not have one-character codes; unspecified should be 0
 #   @unspecified_status = Status.find_by_description('Unspecified')
#    @locations = Location.select("code, city_id, description").order("code")
#    @record.location_id = -1
#    @record.status = Status.find(-1)
#    puts "**** New Family: #{@record.attributes}"
  end

  def create_respond_to_html 
   redirect_to edit_member_path @record.head
  end  

  def create_respond_to_js
   redirect_to edit_member_path @record.head
  end  

end

