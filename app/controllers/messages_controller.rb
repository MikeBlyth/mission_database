class MessagesController < ApplicationController
  active_scaffold :message do |config|
    config.list.columns = [:created_at, :user, :body, :to_groups, :send_sms, :send_email, :importance]
  end

  def do_new
    super
  end

  def do_create
    super
    @record.user = current_user
  end

  def do_edit
    super
    @record.to_groups = YAML.load @record.to_groups # Convert string to integer array
  end
end 
