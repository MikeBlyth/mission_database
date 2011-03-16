class FamiliesController < ApplicationController
  helper :name_column
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :family do |config|
     list.sorting = {:name => 'ASC'}
    config.columns = [:name, :name_override, :first_name, :last_name, :middle_name, :sim_id, :members, :residence_location, :status]
    update.columns.exclude :members 
    update.columns.exclude :members, :first_name, :last_name, :middle_name 
    create.columns.exclude :members
    list.columns.exclude  :name_override, :first_name, :last_name, :middle_name
    config.columns[:status].inplace_edit = true
    config.columns[:residence_location].inplace_edit = true
#    config.update.link = false  # Do not include a link to "Edit" on each line
#    config.delete.link = false  # Do not include a link to "Delete" on each line
    config.columns[:members].associated_limit = nil    # show all members, no limit to how many
    config.columns[:residence_location].form_ui = :select 
    config.columns[:status].form_ui = :select
    config.columns[:name].description = "This is the name by which the family will be known"
    config.columns[:first_name].description = "of individual or head of family"
  
    config.columns[:sim_id].label = "SIM ID"
    config.create.link.page = true 
    config.delete.link.confirm = "\n"+"*" * 60 + "\nAre you sure you want to delete this family and all its members??!!\n" + "*" * 60
  end
  
  def do_update
    puts "**** familes do_update, params=#{params}"
    super
    puts "**** after update family.reslocid=#{@record.residence_location_id}"
  end
  
  def add_family_member
    record = Member.new(:last_name=>'NewMember', :first_name=>'Guess')
    params[:record] = {:last_name=>'NewMember', :first_name=>'Guess'}
    redirect_to new_member_path
  end

  def edit_inline
    
  end  
  def conditions_for_collection
    status_groups = {'active' => %w( field home_assignment mkfield),
                'field' => %w( field mkfield visitor),
                'home_assignment' => %w( home_assignment ),
                'home_assignment_or_leave' => %w( home_assignment leave),
                'pipeline' => %w( pipeline ),
                'visitor' => %w( visitor visitor_past ),
                'other' => %w( alumni college mkadult retired deceased mkalumni unspecified )
                }
      # The groups reflect the status codes matched by the various filters. So, for example,
      #   the filter "active" (or :active) should trigger a selection string that includes the statuses with codes
      #   'field', 'home_assignment', and 'mkfield'

    target_statuses = status_groups[session[:filter]]
    return "TRUE" if target_statuses.nil?
    # Find all status records that match that filter
    matches = [] # This will be the list of matching status ids. 
    Status.where("statuses.code IN (?)", target_statuses).each do |status|
      matches << status.id 
    end
    return ['families.status_id IN (?)', matches]
  end  

  def create_respond_to_html 
   redirect_to edit_member_path @record.head
  end  

  def create_respond_to_js
   redirect_to edit_member_path @record.head
  end  

end

