class MembersController < ApplicationController
  helper :countries
  helper :name_column

  include AuthenticationHelper
  include ApplicationHelper

  before_filter :authenticate #, :only => [:edit, :update]

  active_scaffold :member do |config|

    config.label = "Members"
    list.columns = [:name, 
          :birth_date, :spouse, :family, :country_name, :status, :contacts, :travels, :field_terms]
    list.columns.exclude :travel,
                          :bloodtype, :allergies, :medical_facts, :medications
    list.sorting = {:name => 'ASC'}
    show.columns = create.columns = update.columns = 
        [ :name, :name_override,
          :last_name, :first_name, :middle_name, :short_name, :sex,
          :birth_date, :spouse, 
          :family_name,
          :country_name,
          :date_active, :status, :employment_status,
          :ministry, :ministry_comment, 
          :location, :education, :qualifications,
          :contacts, :field_terms, :travels,
          :bloodtype, :allergies, :medications
          ]
    show.columns.exclude    :last_name, :first_name, :middle_name, :short_name, :name_override
    update.columns.exclude :family_name
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
    config.columns[:location].form_ui = :select 
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
   config.field_search.columns = [:last_name]#, :location, :birth_date, :bloodtype, :status]
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
                              :location => head.location )
        @headline = "Add Spouse for #{head.full_name}"
      elsif params[:type] == 'child'
        @record = Member.new( :family => family,
                              :last_name=> family.last_name, 
                              :country_id => head.country_id,
                              :status => head.status,
                              :date_active => head.date_active,
                              :location => head.location )
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


# criteria based on the filter set in application_controller. 
# it would better to somehow have these defined other than hard-coding the numbers, if the 
# users will have access to the table of statuses! Look up the statuses ahead of time and store?
  def conditions_for_collection
    selector = case
    when session[:filter] == 'active'
      ['members.status_id IN (?)', ['2','3','5']]
    when session[:filter] == 'on_field'
      ['members.status_id IN (?)', ['2','3']]
    when session[:filter] == 'home_assignment'
      ['members.status_id IN (?)', ['5']]
    when session[:filter] == 'ha_or_leave'
      ['members.status_id IN (?)', ['5','6']]
    when session[:filter] == 'pipeline'
      ['members.status_id IN (?)', ['12']]
    when session[:filter] == 'other'
      ['members.status_id NOT IN (?)', ['2','3','5','6','12']]
    else
 #     ['?', true]
      ['members.id > 0']  # no filter; use this if can't get "true" to work
    end

    selector
  end  

end
  
