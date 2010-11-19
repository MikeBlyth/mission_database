class MembersController < ApplicationController
helper :countries

  active_scaffold :member do |config|
    config.label = "Members"
    list.columns = [:name, 
          :birth_date, :spouse, :country_name, :status, :contacts, :travels, :field_terms]
    list.columns.exclude :travel,
                          :bloodtype, :allergies, :medical_facts, :medications
    list.sorting = {:last_name => 'ASC'}
    show.columns = create.columns = update.columns = 
        [ :name, :name_override,
          :last_name, :first_name, :middle_name, :short_name, :sex,
          :birth_date, :spouse, :country_name,
          :date_active, :status, :family_name, :family_head,
          :ministry, :ministry_comment, 
          :location, :education, :qualifications,
          :contacts, :field_terms, :travels,
          :bloodtype, :allergies, :medications
          ]
    show.columns.exclude :last_name, :first_name, :middle_name, :short_name, :name_override
    config.columns[:country].actions_for_association_links = []
    config.columns[:country].css_class = :hidden
    config.columns[:spouse].actions_for_association_links = [:show]
#    config.delete.link = false
 #   config.columns[:country].form_ui = :select 
    config.columns[:bloodtype].form_ui = :select 
  #  config.columns[:spouse].form_ui = :select 
    config.columns[:family].form_ui = :select 
 #   config.columns[:family_id].form_ui = :select 
    config.columns[:education].form_ui = :select 
    config.columns[:sex].options[:options] = [['Female', 'F'], ['Male',
'M']]
    config.columns[:sex].form_ui = :select 
    config.columns[:ministry].form_ui = :select 
    config.columns[:status].form_ui = :select 
    config.columns[:employment_status].form_ui = :select 
    config.columns[:location].form_ui = :select 
    config.columns[:status].inplace_edit = true
    config.columns[:field_terms].collapsed = true
    config.columns[:travels].collapsed = true
    config.columns[:contacts].collapsed = true
  #  config.columns[:family].actions_for_association_links = []
    config.nested.add_scoped_link(:family) 
 
   config.actions.exclude :search
   config.actions.add :field_search
   config.field_search.human_conditions = true
   config.field_search.columns = [:last_name]#, :location, :birth_date, :bloodtype, :status]
  end
  
  def set_full_names
    Member.find(:all).each do |m| 
      if m.name.blank?
        m.update_attributes(:name => m.indexed_name)
      end
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

=begin
 # Form may return the country name or id, so may need to convert to ID before validating
  def country_lookup
 #   country = params[:record][:country]
 #   unless (country.to_i > 0)or country.blank? 
 #     params[:record][:country] = Country.find_by_name(country).id
 #   end
    country_id = Country.find_by_name(params[:record][:country_name]).id
    params[:record][:country] = country_id

    params[:record].delete(:country_name)
  end

  def update
    country_lookup
    super
  end

  def create
    country_lookup
    super
  end
=end

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
      ['true']
    end

    selector
  end  
  
end
  
