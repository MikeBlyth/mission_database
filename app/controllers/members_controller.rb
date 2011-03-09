class MembersController < ApplicationController
  helper :countries
  helper :name_column

  include AuthenticationHelper
  include ApplicationHelper

  before_filter :authenticate #, :only => [:edit, :update]

  active_scaffold :member do |config|

    config.label = "Members"
    list.columns = [:name, 
          :spouse, :residence_location, :work_location, :country_name, :status, :contacts]
    config.columns[:name].sort_by :sql
    config.list.sorting = {:name => 'ASC'}
    show.columns = create.columns = update.columns = 
        [ :name, :name_override,
          :last_name, :first_name, :middle_name, :short_name, :sex,
          :birth_date, :spouse, 
          :family_name,
          :country_name,
          :date_active, :status, :employment_status,
          :ministry, :ministry_comment, 
          :residence_location, :work_location, :temporary_location, :temporary_location_from_date, :temporary_location_until_date,
          :education, :qualifications,
          :contacts, :field_terms, :travels,
          :bloodtype, :allergies, :medications
          ]
    show.columns.exclude    :last_name, :first_name, :middle_name, :short_name, :name_override
    update.columns.exclude :family_name
 
    update.columns = [:name, :name_override,
          :last_name, :first_name, :middle_name, :short_name, :sex,
          :birth_date, :spouse, 
          :family_name,
          :country_name,
          :date_active, :status, :employment_status,
          :ministry, :ministry_comment, 
          :residence_location, :work_location,
          :temporary_location, :temporary_location_from_date, :temporary_location_until_date,         
          :education, :qualifications,
          :bloodtype, :allergies, :medications,
          :contacts, :travels,
           ]
 
    create.columns.exclude :family_name
    config.columns[:country].actions_for_association_links = []
    config.columns[:country].css_class = :hidden
    config.columns[:spouse].actions_for_association_links = [:show]
#    config.delete.link = false
    config.columns[:bloodtype].form_ui = :select 
    config.columns[:family].form_ui = :select 
    config.columns[:education].form_ui = :select 
    config.columns[:sex].options[:options] = [['Female', 'F'], ['Male', 'M']]
    config.columns[:sex].form_ui = :select 
    config.columns[:ministry].form_ui = :select 
    config.columns[:status].form_ui = :select 
    config.columns[:employment_status].form_ui = :select 
  #  config.columns[:residence_location].form_ui = :select 
    config.columns[:residence_location].inplace_edit = true
    config.columns[:work_location].inplace_edit = true
    config.columns[:status].inplace_edit = true
    config.columns[:field_terms].collapsed = true
    config.columns[:travels].collapsed = true
    config.columns[:contacts].collapsed = true
    config.columns[:family].actions_for_association_links = [:list]

    
#    config.columns[:family].link = :show
#    config.nested.add_link("Family", [:family])  # This doesn't seem to work; should add a "Family" link in actions
 #   config.nested.add_scoped_link(:family) 
   config.actions.exclude :search
   config.actions.add :field_search
   config.field_search.human_conditions = true
   config.field_search.columns = [:last_name]#, :residence_location, :birth_date, :bloodtype, :status]
   config.create.link.page = false 
  end


#  def destroy
#puts "**** Members_controller : destroy #{params}, Member.count=#{Member.count}"
#    @member = Member.find(params[:id])
#    @member.destroy
#puts "**** Members_controller: destroyed, Member.count=#{Member.count}"

#    respond_to do |format|
#puts "**** Members_controller: redirecting"
#      format.html { redirect_to(members_url) }
#      format.xml  { head :ok }
#    end
#  end


  def edit_inline
    respond_to do |format|
      puts "**** Edit Inline"
      format.js
    end
  end
  
  def do_new
    super
    if params[:family]
      family = Family.find_by_id(params[:family])
      head = family.head
      if params[:type] == 'spouse'
        @record = Member.new( :family => family,
                              :last_name=> family.last_name, 
                              :sex => opposite_sex(head.sex),
                              :spouse => head,
                              :country_id => head.country_id,
                              :status => head.status,
                              :date_active => head.date_active,
                              :employment_status => head.employment_status,
                              :residence_location => head.residence_location )
        @headline = "Add Spouse for #{head.full_name}"
      elsif params[:type] == 'child'
        @record = Member.new( :family => family,
                              :last_name=> family.last_name, 
                              :country_id => head.country_id,
                              :status => head.status,
                              :date_active => head.date_active,
                              :residence_location => head.residence_location )
        @headline = "Add Child for #{head.full_name}"
      end  

    end
  end

# TODO REMOVE OR DISABLE WHEN FINISHED DEBUGGING
############## ONLY FOR TROUBLESHOOTING! ************************
  def do_show
    super
    if @record.family.nil?
      begin
          f = Family.new(:head => @record)
          f.id = @record.family_id
          f.save
      rescue
         puts "****** ERROR  #{$!}"
      end
    end
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

  # Override the ActiveScaffold method so that we can pass errors in flash
  def do_destroy
    @record = find_if_allowed(params[:id], :delete)
    begin
      self.successful = @record.destroy
    rescue
      flash[:warning] = as_(:cant_destroy_record, :record => @record.to_label)
      flash[:warning] << " because #{@record.errors[:delete]}"
      self.successful = false
    end
  end

# Generate a filter string for use in Member.where(conditions_for_collection)...
# The twist is that we have to use member.status_id in the search string since ActiveScaffold
# is not doing a joined search and we don't have access to the status_code at the time of the 
# filtering. So we either have to be sure to have the record ids pre-coded (brittle) or dynamically
# determine them based on the codes such as 'field' or "home_assignment".
# 
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
    return ['members.status_id IN (?)', matches]
#
# This is how to do it using the pre-determined record ids, which are determined by seeds.rb
# but could be changed as users add or remove statuses!
#    selector = case
#    when session[:filter] == 'active'
#      ['members.status_id IN (?)', ['2','3','5']]
#    when session[:filter] == 'field'
#      ['members.status_id IN (?)', ['2','3', '15']]
#    when session[:filter] == 'home_assignment'
#      ['members.status_id IN (?)', ['5']]
#    when session[:filter] == 'home_assignment_or_leave'
#      ['members.status_id IN (?)', ['5','6']]
#    when session[:filter] == 'pipeline'
#      ['members.status_id IN (?)', ['12']]
#    when session[:filter] == 'visitor'
#      ['members.status_id IN (?)', ['14', '15']]
#    when session[:filter] == 'other'
#      ['members.status_id NOT IN (?)', ['2','3','5','6','12', '14', '15']]
#    else
# #     ['?', true]
#      ['members.id > 0']  # no filter; use this if can't get "true" to work
#    end
#
#  return  selector
  end   # conditions_for_collection

end
  
