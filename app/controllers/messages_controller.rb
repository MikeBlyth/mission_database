
class MessagesController < ApplicationController
  active_scaffold :message do |config|
    config.list.columns = [:created_at, :user, :body,  :send_sms, :send_email, :to_groups, 
        :sent_messages, :importance, :status_summary]
    config.create.link.page = true 
    config.columns[:sent_messages].label = 'Sent to'
    config.columns[:importance].label = 'Imp'
    config.create.link.inline = false 
    config.update.link = false
    config.actions.exclude :update
  end

  def do_new
    super
  end

  def before_create_save(record)
    super
    record.user = current_user
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

#  def do_edit
#    super
#    @record.to_groups = @record.to_groups_array # Convert string to integer array
#  end
end 
