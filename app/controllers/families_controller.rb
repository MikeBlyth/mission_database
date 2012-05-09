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
#    config.show.link = false  # Do not include a link to "Show" on each line
    config.columns[:members].associated_limit = nil    # show all members, no limit to how many
    config.columns[:residence_location].form_ui = :select 
    config.columns[:status].form_ui = :select
    config.columns[:name].description = "This is the name by which the family will be known"
    config.columns[:first_name].description = "of individual or head of family"
  
    config.columns[:sim_id].label = "SIM ID"
    config.create.link.page = true 
    config.delete.link.confirm = "\n"+"*" * 60 + "\nAre you sure you want to delete this family and all its members??!!\n" + "*" * 60
  end
  
  # Update a "record" with paramater hash "update_params". If there are errors, add "record" to
  # the list "error_recs". This will be used by the built-in error-message-creator
  def update_and_check(record, update_params, error_recs)
    return unless record   # ignore empty records
    unless record.update_attributes(update_params)
      error_recs << record
    end
  end

  # Fix up some stuff since we're using a customized form, not AS
  def do_edit
    super
    @head = @record.head
    @wife = @record.wife
    @children = @head.children 
  end
    

  # Intercept record after it's been found by AS update process, before it's been changed, and
  #   save the existing residence_location and status so Family model can deal with any changes
  #   (Family.rb update_member_locations and update_member_status update all the family members
  #   if the _family_ location or status has been changed)
  def update
#    puts "==============================================================="
#    puts "Params=#{params}, id=#{params[:id]}"
#    puts "==============================================================="
    @family = Family.find(params[:id])

    # Delete :status_id and :residence_location_id if they have not changed, because
    #   changed ones only will be propagated to the dependent family members.    
    if params[:record][:status_id] == @family.status_id
      params[:record].delete :status_id
    end
    if params[:record][:residence_location_id] == @family.residence_location_id
      params[:record].delete :residence_location_id
    end

    @head = @family.head
    @wife = @family.wife
    @error_records = []  # These are the model records that had errors when updated
    if @head
      update_and_check(@head, params[:head], @error_records)
      update_and_check(@head.personnel_data, params[:head_pers], @error_records)
      update_and_check(@head.primary_contact, params[:head_contact], @error_records)
    end
    if @wife
      update_and_check(@wife, params[:wife], @error_records)
      update_and_check(@wife.personnel_data, params[:wife_pers], @error_records)
      update_and_check(@wife.primary_contact, params[:wife_contact], @error_records)
    end
    # Update the children
    if params[:member]  # for now, this is how children are listed (:member)
      params[:member].each do |id, child_data|
        this_child = Member.find(id)
        this_child_personnel_data = child_data.delete(:personnel_data)
        update_and_check(this_child, child_data, @error_records)
        update_and_check(this_child.personnel_data, this_child_personnel_data, @error_records)
      end
    end
    update_and_check(@family, params[:record], @error_records)
    # May need to update data for family members, based on changes in corresponding fields for family
    update_members_status_and_location(@family)
    if @error_records.empty?
      redirect_to families_path
    else
      @record = @family
      @children = @head.children 
      # Need to remove these from params so that they don't get stuck onto form URL parameters.
      # (Symptom of the problem is that a field can't be changed after an error)
      [:head, :head_pers, :head_contact,
       :wife, :wife_pers, :wife_contact,
       :record, :family, :member,
       :authenticity_token
       ].each {|key| params.delete key}
      respond_to do |format|
        format.js {render :on_update_err, :locals => {:xhr => true}}
        format.html {render :update}
      end
    end      
  end    

  # If a (residence_)location or status have been specified for the family, then
  # apply them to each of the members. 
  def update_members_status_and_location(family)
    updates = {}
    if params[:record][:residence_location_id]
      updates[:residence_location_id] = params[:record][:residence_location_id]
    end
    if params[:record][:status_id]
      updates[:status_id] = params[:record][:status_id]
    end
    unless updates.empty?
#      puts "Updating dependents with #{updates}"
      family.dependents.each {|m| m.update_attributes(updates)}
    end
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
    Status.filter_condition_for_group('families',session[:filter])
  end   # conditions_for_collection

  def create_respond_to_html 
#puts "create_respond_to_html: @record=#{@record}, valid=#{@record.valid?}, path=#{edit_member_path @record.head}"
   redirect_to edit_member_path @record.head if @record.valid?
  end  

  def create_respond_to_js
   redirect_to edit_member_path @record.head if @record.valid?
  end  

end

