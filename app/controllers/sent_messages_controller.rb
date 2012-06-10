class SentMessagesController < ApplicationController
  active_scaffold :sent_message do |config|
    config.list.columns = [:message_id, :member_id, :status, :confirmed_time, :delivery_modes, :confirmed_mode, :confirmation_message]
  end
end 
