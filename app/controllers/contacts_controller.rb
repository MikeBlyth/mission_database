require 'authentication_helper'

class ContactsController < ApplicationController

  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper

  active_scaffold :contact do |config|
    config.columns = [:member, :contact_type, :is_primary, :contact_name, :address, 
    :phone_1, :phone_2, :phone_private, 
    :email_1, :email_2, :email_private,
    :skype, :skype_private,
    :facebook, :blog, :other_website, :photos]
    list.columns = [:member, :contact_type, :is_primary, :contact_name, :address, :phone_1, :email_1]
    config.columns[:member].actions_for_association_links = [:show]
    config.columns[:contact_type].actions_for_association_links = [:show]
    update.columns.exclude :member
    config.columns[:contact_type].form_ui = :select 
    config.columns[:contact_type].inplace_edit = true
    config.columns[:is_primary].inplace_edit = true
    config.columns[:contact_name].inplace_edit = true
    config.columns[:address].inplace_edit = true
    config.columns[:phone_1].inplace_edit = true
    config.columns[:email_1].inplace_edit = true
    config.columns[:contact_name].description = 
      "Person this record applies to, if not member"
    config.columns[:phone_private].description = "Tick box if phone number is considered private/confidential"
    config.columns[:is_primary].description = "Tick box if this is the primary contact record"
    config.columns[:skype_private].description = "Tick box if Skype name is considered private"
    config.columns[:email_private].description = "Tick box if email address is considered private"
   config.subform.layout = :vertical
 #    list.sorting = {:member.last_name => 'ASC'}
  end

  # Set is_primary true if new record belongs to a member with no primary contact or if
  # it belongs to no member at all.
  def do_new
    super
    @record.is_primary = (@record.member && @record.member.contacts.where(:is_primary=>true).empty?) ||
                          @record.member.nil?
  end

end 

