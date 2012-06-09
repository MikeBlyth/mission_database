class MessagesController < ApplicationController
  active_scaffold :message do |config|
    config.list.columns = [:created_at, :user, :body, :to_groups, :send_sms, :send_email, :importance]
  end

  def do_new
    super
    [:confirm_time_limit, :retries, :retry_interval, :expiration, :response_time_limit, :importance].each do |setting|
      @record.send "#{setting}=", Settings.messages[setting]
    end
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
