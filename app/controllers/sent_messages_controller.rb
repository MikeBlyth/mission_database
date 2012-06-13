class SentMessagesController < ApplicationController
  active_scaffold :sent_message do |config|
    config.list.columns = [:message_id, :member_id, :status, :confirmed_time, :delivery_modes, :confirmed_mode, :confirmation_message]
  end

  def update_status_clickatell
    parsed = ClickatellGateway.parse_status_params(params)  # Let Gateway be responsible for understanding the params
    @sent_message = SentMessage.find_by_gateway_message_id parsed[:gateway_msg_id]  # The message whose status is being reported
    @sent_message.update_attributes(parsed[:updates])
    render :text => "Success", :status => 200
  end
end 
