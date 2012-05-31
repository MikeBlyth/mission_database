class MembersController < ApplicationController
  helper :countries
  helper :name_column

  load_and_authorize_resource

  include AuthenticationHelper
  include ApplicationHelper

  before_filter :authenticate #, :only => [:edit, :update]

  active_scaffold :member do |config|

    # Enable user-configurable listing (user can select and order columns)
    config.actions << :config_list
    # We will not be creating any members through ActiveScaffold
    config.actions.exclude :create

    config.label = "Members"
    list.columns = [:name, :spouse, 
          :child, :work_location, :ministry, :travels, :field_terms, :status, :contacts]
    config.columns[:name].sort_by :sql
    config.list.sorting = {:name => 'ASC'}
    show.columns = update.columns = [:name, :name_override,
          :family,
          :last_name, :first_name, :middle_name, :short_name, :sex,
          :child,
          :birth_date, :spouse, 
          :family_name,
          :country_name,
          :status, 
          :ministry, :ministry_comment, 
          :work_location, :temporary_location, :temporary_location_from_date, :temporary_location_until_date,
          :personnel_data, :field_terms, 
          :contacts, :travels,
          :health_data,
          ]
    show.columns.exclude    :last_name, :first_name, :middle_name, :short_name, :name_override
    update.columns.exclude :family_name
    
#    create.columns.exclude :family_name
    config.columns[:country].actions_for_association_links = []
    config.columns[:country].css_class = :hidden
    config.columns[:spouse].actions_for_association_links = [:show]
    config.columns[:family].form_ui = :select 
    config.columns[:education].form_ui = :select 
    config.columns[:sex].options[:options] = [['Female', 'F'], ['Male', 'M']]
    config.columns[:sex].form_ui = :select 
    config.columns[:ministry].form_ui = :select 
    config.columns[:ministry].inplace_edit = true
    config.columns[:status].form_ui = :select 
    config.columns[:status].inplace_edit = true
    config.columns[:child].inplace_edit = true
    config.columns[:work_location].inplace_edit = true
#    config.columns[:field_terms].collapsed = true
    config.columns[:field_terms].associated_limit = 2
#    config.columns[:health_data].collapsed = true
#    config.columns[:travels].collapsed = true
    config.columns[:travels].associated_limit = 2
#    config.columns[:contacts].collapsed = true
    config.columns[:family].actions_for_association_links = [:list]
    
   config.actions.exclude :search
   config.actions.add :field_search
   config.field_search.human_conditions = true
   config.field_search.columns = [:last_name]#, :residence_location, :birth_date, :bloodtype, :status]
#   config.create.link.page = false 
#   config.update.link.inline = false  # un-comment to force member edits to be normal html (not Ajax)
#   config.update.link.page = true     # un-comment to force member edits to be normal html (not Ajax)
  end

  # Given params hash, change :something_id to :something
  def convert_keys_to_id(params, *keys_to_change)
    return params if keys_to_change.nil? || params.nil?
    keys_to_change.each do |k|
      v = params.delete(k)
      params[(k.to_s << '_id').to_sym] = v unless v.blank?  # resinsert value but with _id added to key
    end
    params
  end

  def update_field_terms(member, params)
    return if params.nil? || (params[:end_date].blank? && params[:start_date].blank?)
    id = params.delete('id')
    field_term = id.nil? ? member.field_terms.new : FieldTerm.find(id) 
    field_term.update_attributes(params)
  end
  
  def do_edit
    super
#puts "**** @record.attributes=#{@record.attributes}"
#puts "**** @record.head=#{@record.head}"
    @head = @record
    @head_contact = @head.primary_contact
    @head_pers = @head.personnel_data
    @current_term = @head.most_recent_term || FieldTerm.new(:member=>@head)
    @next_term = @head.pending_term || FieldTerm.new(:member=>@head)
    @head_health = @head.health_data
  end

  # add "_id" to the key in hash (AS update seems to not require the _id but we do)
  def add_id_to_key(hash,key)
    return unless hash && key && hash[key]
    hash[key+"_id"] = hash[key]
    hash.delete key
  end
    
  def update
# puts "\n**** Full params=#{params}, id=#{params[:id]}"
    @head = Member.find(params[:id])
#    params.delete[:health_data] unless can? :update HealthData
    @error_records = []  # Keep list of the model records that had errors when updated
      @head, @head_pers, @head_contact, @health_data = 
        update_one_member(@head, params[:head], params[:head_pers], params[:head_contact],
           params[:health_data], @error_records)
    # Apply to head and spouse any changes to current_term.end_date or next_term.start_date
    #  from Family tab. These _override_ any changes made on the head or wife pages
    update_field_terms(@head, params[:current_term])
    update_field_terms(@head, params[:next_term])

    if @error_records.empty?
      redirect_to members_path
    else  # send back to user to try again
      @record = @head
      remove_unneeded_keys(params)
      respond_to do |format|
        format.js {render :on_update_err, :locals => {:xhr => true}}
        format.html {render :update}
      end
    end      
  end   
  
  def new
      redirect_to members_path
  end

  def do_show
    super
  end    
  
#  def update_save(params={})
#    @record.previous_spouse = @record.spouse if @record
#    super(params)
#  end    
  
  # Override the ActiveScaffold method so that we can pass errors in flash
  def do_destroy
    @record = find_if_allowed(params[:id], :delete)
#    @record.previous_spouse = @record.spouse
    begin
      self.successful = @record.destroy
    rescue
      flash[:warning] = as_(:cant_destroy_record, :record => @record.to_label)
      flash[:warning] << " because #{@record.errors[:delete]}"
      self.successful = false
    end
  end

  def update_statuses
    params.each do |member, status_id|
      if member =~ /member_(\d+)/
        new_status = status_id[:status_id].to_i
        Member.find($1.to_i).update_attribute(:status_id, new_status)
      end
    end
    redirect_to(status_mismatch_report_path)
  end
        
  def export(columns=%w{last_name first_name name birth_date sex country ministry work_location})
     send_data Member.export(columns), :filename => "members.csv"
  end

  def set_full_names
    Member.find(:all).each do |m| 
      if m.name.blank? || (m.first_name == m.short_name)
        m.update_attributes(:name => m.indexed_name)
      end
      m.name = m.name.strip if m.name[-1]= ' '
    end
    redirect_to(:action => :index)
  end
 
  def spouse_select
    my_last_name = params[:name]
    my_sex = params[:sex]
    # For existing members, retrieve the existing database record and 
    #   TEMPORARILY change the last_name and sex to conform
    #   with the request. This change is not saved!
    if params[:id] && params[:id] != 'new' # Do we know the exact person we're dealing with?
      my_id = params[:id]
      me = Member.find(my_id)
      me.last_name = my_last_name
      me.sex = my_sex
    # For new members (no ID yet, still being created)
    #   make up a temporary, incomplete "shadow" member to use for finding spouses;
    #   we don't know the id, but we need at least the last name and sex
    else  
      # then 
      me = Member.new(:last_name=>my_last_name, :sex=>my_sex)
    end
    @json_resp = []  # start with an empty response set
    my_possible_spouses = me.possible_spouses
    if my_possible_spouses  # i.e. if there are any possibilities
      my_possible_spouses.each do |c|
        @json_resp << {:name=>c.name, :id=>c.id}
      end
    end
    @json_resp << {:name => '--Other--' , :id => ''} <<
                  {:name => '--None--' , :id => ''} 
puts "@json_resp = #{@json_resp}"
    respond_to do |format|
      format.js { render :json => @json_resp }
    end
  end

# Generate a filter string for use in Member.where(conditions_for_collection)...
  def conditions_for_collection
    Status.filter_condition_for_group('members', session[:filter])
  end   # conditions_for_collection


end
  
