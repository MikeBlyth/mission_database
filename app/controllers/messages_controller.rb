
class MessagesController < ApplicationController
  include AuthenticationHelper
  include AuthorizationHelper

load_and_authorize_resource

  active_scaffold :message do |config|
    config.list.columns = [:id, :created_at, :user, :body,  :send_sms, :send_email, :to_groups, 
        :sent_messages, :importance, :status_summary]
    config.create.link.page = true 
    config.columns[:sent_messages].label = 'Sent to'
    config.columns[:importance].label = 'Imp'
    config.create.link.inline = false 
    config.update.link = false
    config.actions.exclude :update
    list.sorting = {:created_at => 'DESC'}
  end

  def do_new
    super
  end

  def before_create_save(record)
    super
    record.user = current_user if current_user
  end

  def after_create_save(record)
    super
    deliver_message(record)
  end
  
  def deliver_message(record)
    if Rails.env == 'production'
      sms_gateway = ClickatellGateway.new
    else
      sms_gateway = MockClickatellGateway.new
    end
    record.deliver(:sms_gateway => sms_gateway)
  end

  # Send form to user for generating a follow-up on a given message
  def followup
    @id = params[:id]
    @record = Message.find @id
  end
  
  # Use form from 'followup' to generate new message
  def followup_send
    @id = params[:id]  # Id of original message
    original_message = Message.find @id
    fu_message = Message.create(params[:record].merge(:following_up => @id))  # a new message object to send the follow up
    fu_message.members = original_message.members_not_responding
    fu_message.deliver
    flash[:notice] = 'Follow up message sent'
    redirect_to messages_path
  end
   
end 
