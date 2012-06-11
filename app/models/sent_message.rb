# == Schema Information
# Schema version: 20120609195703
#
# Table name: sent_messages
#
#  id                   :integer         not null, primary key
#  message_id           :integer
#  member_id            :integer
#  status               :integer
#  confirmed_time       :datetime
#  delivery_modes       :string(255)
#  confirmed_mode       :string(255)
#  confirmation_message :string(255)
#  attempts             :integer

class SentMessage < ActiveRecord::Base
  belongs_to :message
  belongs_to :member

  def send_to_gateways
    self.attempts ||= 0
    return nil if attempts > message.retries # Do nothing if we've already tried enough times
    @contact = member.primary_contact
    return false unless @contact
    send_email if message.send_email && @contact.email_1
    send_sms if message.send_sms && @contact.phone_1
    update_attributes(:attempts=>attempts+1)
  end

  def send_email
    message = Notifier.send_generic([@contact.email_1], self.body)
    message.deliver
  end

  def send_sms
    gateway = gateway = ClickatellGateway.new
    gateway.deliver(@contact.phone_1, self.body[0..150])        
  end
end
