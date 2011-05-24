class FamiliesController < ApplicationController
  helper :name_column
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  include ApplicationHelper
  
  active_scaffold :family do |config|
     list.sorting = {:name => 'ASC'}
    config.columns = [:name, :name_override, :first_name, :last_name, :middle_name, :sim_id, :members, :residence_location, :status]
    update.columns.exclude :members 
    update.columns.exclude :members, :first_name, :last_name, :middle_name 
    create.columns.exclude :members
    list.columns.exclude  :name_override, :first_name, :last_name, :middle_name
    update.columns << :head
    config.columns[:head].form_ui = :select
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
  
  # Intercept record after it's been found by AS update process, before it's been changed, and
  #   save the existing residence_location and status so Family model can deal with any changes
  def update_save(params={})
    if @record
      @record.previous_residence_location = @record.residence_location 
      @record.previous_status = @record.status
    end  
    super(params)
  end    

  def do_create
    super
    if !@record.valid?
      puts "Invalid new family -- errors: #{@record.errors}"
        render :action => "create" 
      return
    end
    create_family_head(@record)
  end    
  
   # Creating a new family ==> Need to create the member record for head
  def create_family_head(record)
    head = Member.create(:name=>record.name, :last_name=>record.last_name, 
            :first_name=>record.first_name, 
            :middle_name => record.middle_name,
            :status_id=>record.status_id, 
            :residence_location_id=>record.residence_location_id, 
            :family_id =>record.id, :sex=>'M')
    if ! head.valid?
      errors.add(:head, "Unable to create head of family")
      raise ActiveRecord::Rollback
    end   
    record.update_attributes(:head => head)  # Record newly-created member as the head of family

  end

  def add_family_member
    record = Member.new(:last_name=>'NewMember', :first_name=>'Guess')
    params[:record] = {:last_name=>'NewMember', :first_name=>'Guess'}
    redirect_to new_member_path
  end

# Generate a filter string for use in Family.where(conditions_for_collection)...
  def conditions_for_collection
    Status.filter_condition_for_group(session[:filter])
  end   # conditions_for_collection

  def create_respond_to_html 
#puts "create_respond_to_html: @record=#{@record}, valid=#{@record.valid?}, path=#{edit_member_path @record.head}"
   redirect_to edit_member_path @record.head if @record.valid?
  end  

  def create_respond_to_js
   redirect_to edit_member_path @record.head if @record.valid?
  end  

end

