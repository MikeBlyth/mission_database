class GroupsController < ApplicationController
#  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  load_and_authorize_resource

  
  active_scaffold :group do |config|
    # list.columns.exclude :abo, :rh, :members
    config.columns = [:group_name, :type_of_group, :members,  :parent_group]
    list.sorting = {:group_name => 'ASC'}
    config.show.link = false
    config.columns[:group_name].inplace_edit = true
    config.columns[:type_of_group].inplace_edit = true
    config.columns[:parent_group].inplace_edit = true
    config.columns[:parent_group].form_ui = :select 
  end
end
