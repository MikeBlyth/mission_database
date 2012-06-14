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
  require 'mail'
  belongs_to :message
  belongs_to :member

  def send_to_gateways
    self.attempts ||= 0
    return nil if attempts > message.retries # Do nothing if we've already tried enough times
    @contact = member.primary_contact
    return false unless @contact
    send_email if message.send_email && @contact.email_1
    send_sms if message.send_sms && @contact.phone_1
    update_attributes(:attempts=>attempts+1, :gateway_message_id=>@gateway_message_id)
  end

  def send_email
    outgoing = Notifier.send_generic([@contact.email_1], message.body)
    outgoing.deliver
  end

  def send_sms
#puts "send_sms"
    if Rails.env != 'development'
      gateway = ClickatellGateway.new
    else  
      gateway = SmsGateway.new  # just for testing
    end
    gateway_reply = gateway.deliver(@contact.phone_1, message.body[0..149] + ' ' + message.timestamp)        
#puts "**** gateway_reply=#{gateway_reply}"
    if gateway_reply =~ /ID: (\w+)/
      @gateway_message_id = $1
    else
      @gateway_message_id = gateway_reply  # Will include error message
    end
#puts "**** @gateway_message_id=#{@gateway_message_id}"
  end

end
