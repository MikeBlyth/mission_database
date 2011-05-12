require 'authentication_helper'

class ContactsController < ApplicationController

  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper

  active_scaffold :contact do |config|
    list.columns = [:member, :contact_type, :contact_name, :address, :phone_1, :email_1]
    config.columns[:member].actions_for_association_links = [:show]
    config.columns[:contact_type].actions_for_association_links = [:show]
    update.columns.exclude :member
    config.columns[:contact_type].form_ui = :select 
    config.columns[:contact_type].inplace_edit = true
    config.columns[:contact_name].inplace_edit = true
    config.columns[:address].inplace_edit = true
    config.columns[:phone_1].inplace_edit = true
    config.columns[:email_1].inplace_edit = true
    config.columns[:phone_private].description = "Tick box if phone number is considered private/confidential"
    config.columns[:skype_private].description = "Tick box if Skype name is considered private"
    config.columns[:email_private].description = "Tick box if email address is considered private"
   config.subform.layout = :vertical
 #    list.sorting = {:member.last_name => 'ASC'}
  end

end 

