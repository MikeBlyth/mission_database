class SentMessagesController < ApplicationController
  active_scaffold :sent_message do |config|
    config.list.columns = [:message, :member, :msg_status, :confirmed_time, :confirmed_mode, :confirmation_message]
    config.subform.columns.exclude :message
  end
  include AuthenticationHelper
  load_and_authorize_resource

  def update_status_clickatell
    parsed = ClickatellGateway.parse_status_params(params)  # Let Gateway be responsible for understanding the params
    @sent_message = SentMessage.find_by_gateway_message_id parsed[:gateway_msg_id]  # The message whose status is being reported
    @sent_message.update_attributes(parsed[:updates]) if @sent_message
    AppLog.create(:code => "SMS.clickatell.update", :description=>"params=#{params}")
    render :text => "Success", :status => 200
  end
end 
