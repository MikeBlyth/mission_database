class MessagesController < ApplicationController
  active_scaffold :message do |config|
    config.list.columns = [:created_at, :user, :body,  :send_sms, :send_email, :to_groups, :importance]
  end

  def do_new
    super
  end

  def before_create_save(record)
    super
    record.user = current_user
  end

  def do_edit
    super
    @record.to_groups = @record.to_groups_array # Convert string to integer array
  end
end 
