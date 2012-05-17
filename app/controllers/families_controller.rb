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

  # Return new records for 'count' children of 'parent'. Records are not saved.
  # This is used for to create the edit and update form where children are listed,
  # so that there will be space to add new ones.
  def new_children(parent, count=1)
    new_kids = []
    for i in 1..count do
      m = Member.new(:last_name => parent.last_name, :first_name => '', 
                  :family => parent.family)
      m.id = 1000000000+i
      new_kids << m
    end
    return new_kids
  end

  # When creating the Edit form, fix up some stuff since we're using a customized form, not AS
  def do_edit
    super
# puts "**** @record.attributes=#{@record.attributes}"
    @head = @record.head
    @head_contact = @head.primary_contact
    @wife = @record.wife 
    @wife_contact = @wife.primary_contact if @wife
    if @wife.nil? && @head.male?
      @wife = Member.new(:last_name=>@head.last_name, :personnel_data=>PersonnelData.new)
    end
    @children = (@head.children(true) + new_children(@head,1)) if @head  # (true) means include grown children
  end
    
  def do_new
    super
    @head = Member.new(:personnel_data=>PersonnelData.new)
    @wife = Member.new(:personnel_data=>PersonnelData.new)
    @children = new_children(@head,5)
    @error_records = []
  end
    
  def update_one_member(member, member_params, pers_rec, pers_params, contact_rec, contact_params, error_recs)
    update_and_check(member, member_params, error_recs)
    pers_rec = member.personnel_data || PersonnelData.new
    update_and_check(pers_rec, pers_params, error_recs)
    contact_rec = member.primary_contact || member.contacts.new
    update_and_check(contact_rec, contact_params, error_recs)
  end   

  # Need to remove these from params so that they don't get stuck onto form URL parameters.
  # (Symptom of the problem is that a field can't be changed after an error, get "URL too Long" error)
  def remove_unneeded_keys(params)
      [:head, :head_pers, :head_contact,
        :wife, :wife_pers, :wife_contact,
        :record, :family, :member,
        :authenticity_token
      ].each {|key| params.delete key}
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
    if params[:record][:status_id] == @family.status_id  # i.e. it's unchanged
      params[:record].delete :status_id
    end
#*    if params[:record][:residence_location_id] == @family.residence_location_id
#*      params[:record].delete :residence_location_id
#*    end

    @head = @family.head
    @wife = @family.wife
    @error_records = []  # Keep list of the model records that had errors when updated
    if @head
      update_one_member(@head, params[:head], @head_pers, params[:head_pers], @head_contact, params[:head_contact], @error_records)
    end
    # If there ARE parameters defining wife, then create or update wife
    if params[:wife] && !params[:wife][:first_name].blank?
      @wife ||= @head.create_wife # Need to create one if it doesn't exist
      update_one_member(@wife, params[:wife], @wife_pers, params[:wife_pers], @wife_contact, params[:wife_contact], @error_records)
    end  
    # Update the children
    if params[:member]  # for now, this is how children are listed (:member)
      params[:member].each do |id, child_data|
        if id.to_i > 1000000000  # i.e. if this is definition of a new child
          if !child_data[:first_name].empty?  # and has data (as opposed to being just the blank line being returned
            new_child = @family.add_child child_data  # create the new child
            @error_records << new_child unless new_child.errors.empty?
          end
        else
          this_child = Member.find(id)
          this_child_personnel_data = child_data.delete(:personnel_data)  # to be updated separately
          update_and_check(this_child, child_data, @error_records)
          update_and_check(this_child.personnel_data, this_child_personnel_data, @error_records)
        end
      end
    end
    update_and_check(@family, params[:record], @error_records)
    # May need to update data for family members, based on changes in corresponding fields for family
    update_members_status_and_location(@family)

    if @error_records.empty?
      redirect_to families_path
    else  # send back to user to try again
      @record = @family
      @children = @head.children + new_children(@head,1)
      remove_unneeded_keys(params)
      respond_to do |format|
        format.js {render :on_update_err, :locals => {:xhr => true}}
        format.html {render :update}
      end
    end      
  end   
  
  def create
 #   puts "Families_controller#create"
#    puts "Params=#{params}, id=#{params[:id]}"
    @error_records = []  # Keep list of the model records that had errors when updated
    @family = Family.new
    @head = Member.new(:family=>@family)
    update_and_check(@family, params[:record], @error_records)
    update_one_member(@head, params[:head], @head_pers, params[:head_pers], @head_contact, params[:head_contact], @error_records)
    @family.update_attributes(:head=>@head)   # Set family head

    # If there ARE parameters defining wife, then create wife
    if params[:wife] && !params[:wife][:first_name].blank?
      @wife = @head.create_wife 
      update_one_member(@wife, params[:wife], @wife_pers, params[:wife_pers], @wife_contact, params[:wife_contact], @error_records)
    end  
    # Add children
    @children = []
    if params[:member]  # for now, this is how children are listed (:member)
      params[:member].each do |id, child_data|
        if !child_data[:first_name].empty?  # and has data (as opposed to being just the blank line being returned
          new_child = @family.add_child child_data  # create the new child
          new_child.id = id
          @children << new_child
          @error_records << new_child unless new_child.errors.empty?
        end # adding one child
      end # adding children
    end # if any children are specified

    if @error_records.empty?
      redirect_to families_path
    else  # send back to user to try again
      # Need to remove these from params so that they don't get stuck onto form URL parameters.
      # (Symptom of the problem is that a field can't be changed after an error, get "URL too Long" error)
      remove_unneeded_keys(params)
      @family.destroy  # remove the database entry for family and members
      @head.personnel_data = PersonnelData.new
      @wife ||= Member.new(:family=>@family)
      @wife.personnel_data = PersonnelData.new
      @record = @family
      respond_to do |format|
        format.html {render :create}
      end
    end    
  end 

  # If a (residence_)location or status have been specified for the family, then
  # apply them to each of the members. 
  def update_members_status_and_location(family)
    updates = {}
#*    if params[:record][:residence_location_id]
#*      updates[:residence_location_id] = params[:record][:residence_location_id]
#*    end
    if params[:record][:status_id]
      updates[:status_id] = params[:record][:status_id]
    end
    unless updates.empty?
      family.dependents.each {|m| m.update_attributes(updates)}
    end
  end
  
# Generate a filter string for use in Family.where(conditions_for_collection)...
  def conditions_for_collection
    Status.filter_condition_for_group('families',session[:filter])
  end   # conditions_for_collection

#  def create_respond_to_html 
##puts "create_respond_to_html: @record=#{@record}, valid=#{@record.valid?}, path=#{edit_member_path @record.head}"
#   redirect_to edit_member_path @record.head if @record.valid?
#  end  

#  def create_respond_to_js
#   redirect_to edit_member_path @record.head if @record.valid?
#  end  

end

