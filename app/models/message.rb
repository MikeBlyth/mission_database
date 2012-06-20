# == Schema Information
# Schema version: 20120613213558
#
# Table name: messages
#
#  id                  :integer         not null, primary key
#  body                :string(255)
#  from_id             :integer
#  code                :string(255)
#  confirm_time_limit  :integer
#  retries             :integer
#  retry_interval      :integer
#  expiration          :integer
#  response_time_limit :integer
#  importance          :integer
#  to_groups           :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  send_email          :boolean
#  send_sms            :boolean
#  user_id             :integer
#

class Message < ActiveRecord::Base
  has_many :sent_messages
  has_many :members, :through => :sent_messages  # May not be needed, 
  belongs_to :user
  validates_numericality_of :confirm_time_limit, :retries, :retry_interval, :expiration, :response_time_limit, :importance
      
  validates_presence_of :body, :message=>'You need to write something in your message!'
  validates_presence_of :to_groups, :message=>'Select at least one group to receive message.'
  validate :sending_medium
  before_save :convert_groups_to_string
  after_save  :create_sent_messages   # each record represents this message for one recipient
  
  def after_initialize
    [:confirm_time_limit, :retries, :retry_interval, :expiration, :response_time_limit, :importance].each do |setting|
      self.send "#{setting}=", Settings.messages[setting] if (self.send setting).nil?
    end
  #  user = current_user 
  end   
  
  # Convert :to_groups=>["1", "2", "4"] or [1,2,4] to "1,2,4", as maybe 
  #    simpler than converting with YAML
  def convert_groups_to_string
    if self.to_groups.is_a? Array
      self.to_groups = self.to_groups.map {|g| g.to_i}.join(",")
    end
  end 

  def to_s
    "#{timestamp}: #{body[0..50]}"
  end

  def create_sent_messages
#puts "**** create_sent_messages"
    target_members = Group.members_in_multiple_groups(to_groups_array) & # an array of users
                     Member.those_in_country
#puts "**** target_members=#{target_members}"
    self.members = target_members
#puts "**** target_members=#{target_members}"
#puts "**** target_members.first.primary_contact=#{target_members.first.primary_contact}"
  end
  
  # Send the messages -- done by creating the sent_message objects, one for each member
  #   members_in_multiple_groups(array) is all the members belonging to these groups and
  #   to_groups_array is the array form of the destination groups for this message
  def deliver(params={})
    puts "**** Message#deliver" if params[:verbose]
    if send_email
      email_addresses = members.map {|m| m.primary_contact.email_1}
      deliver_email(email_addresses)
    end
    if send_sms
      phone_numbers = members.map {|m| m.primary_contact.phone_1.gsub('+','')}
      deliver_sms(:sms_gateway=>params[:sms_gateway], :phone_numbers => phone_numbers)
    end
    #*********STUB!***********
#    self.sent_messages.each {|m| m.update_attributes(:gateway_message_id=>'AAAAAAAAAAAAAAAAAAA')}
#puts "**** email_addresses=#{email_addresses}"
  end

  def timestamp
    t = created_at.getlocal
    hour = t.hour
    if (0..9).include?(hour) || (13..21).include?(hour)
      (t.strftime('%e%b')+t.strftime('%l')[1]+t.strftime(':%M%P'))[0..9]
    else
      t.strftime('%e%b%l%M%P')[0..9]
    end
  end
  
  def to_groups_array
    to_groups.split(",").map{|g| g.to_i} if to_groups
  end

  def sent_messages_pending
    sent_messages.map {|m| m if m.msg_status == MessagesHelper::MsgSentToGateway || 
                               m.msg_status == MessagesHelper::MsgPending}.compact
  end                               
  
  def sent_messages_errors
    sent_messages.map  {|m| m if m.msg_status == MessagesHelper::MsgError || m.msg_status.nil?}.compact
  end                               
  
  def sent_messages_delivered
    sent_messages.map {|m| m if m.msg_status == MessagesHelper::MsgDelivered}.compact
  end                               
  
  def sent_messages_replied
    sent_messages.map {|m| m if m.msg_status == MessagesHelper::MsgResponseReceived}.compact
  end                               
  
  def current_status
#puts "**** current_status"
    errors = sent_messages_errors
    errors_names = errors.map{|m| m.member.shorter_name}.join(', ')
    pending = sent_messages_pending
    pending_names = pending.map{|m| m.member.shorter_name}.join(', ')
    delivered = sent_messages_delivered
    delivered_names = delivered.map{|m| m.member.shorter_name}.join(', ')
    replied = sent_messages_replied
    replied_names = replied.map{|m| m.member.shorter_name}.join(', ')

    status = {:errors=>errors.size, :errors_names => errors_names,
              :pending=>pending.size, :pending_names => pending_names,
              :delivered=>delivered.size, :delivered_names => delivered_names,
              :replied=>replied.size, :replied_names => replied_names
              }
  end

private

  def deliver_email(emails)
#puts "**** deliver_email: emails=#{emails}"
    outgoing = Notifier.send_generic(emails, self.body, true) # send using bcc:, not to:
raise "send_email with nil email produced" if outgoing.nil?
    outgoing.deliver
  end
  
  def deliver_sms(params)
    sms_gateway = params[:sms_gateway]
    phone_number_array = params[:phone_numbers]
    phone_numbers = phone_number_array.join(',')
  #  insert_response_tags if response_time_limit
#puts "**** sms_gateway.deliver=#{sms_gateway.deliver}"
    gateway_reply = 
      sms_gateway.deliver(phone_numbers, self.body[0..149] + ' ' + self.timestamp)
#puts "**** gateway_reply=#{gateway_reply}"
#puts "**** phone_numbers=#{phone_numbers}"
    ######## SINGLE PHONE NUMBER ########
    if phone_number_array.size == 1
      if gateway_reply =~ /ID: (\w+)/
        gtw_msg_id = $1
        msg_status = MessagesHelper::MsgSentToGateway
      else
        gtw_msg_id = gateway_reply  # Will include error message
        msg_status = MessagesHelper::MsgError
#puts "**** gtw_msg_id=#{gtw_msg_id}, msg_status=#{msg_status}"
      end
      self.sent_messages[0].update_attributes(
          :gateway_message_id => gtw_msg_id, 
          :msg_status=>msg_status
          )
#puts "**** gtw_msg_id=#{gtw_msg_id}, msg_msg_status=#{msg_msg_status}"
    else
      ####### MULTIPLE PHONE NUMBERS ################
      msg_statuses = gateway_reply.split("\n").map do |s|
        if s =~ /ID:\s+(\w+)\s+To:\s+([0-9]+)/
          {:id=>$1, :phone=>"+" + $2}    # Add '+' to phone number for matching from database
        else
          {:id=>nil, :phone=>nil, :error=>s}
        end
      end
#puts "**** msg_statuses=#{msg_statuses}"
      member = nil
      @member_phones = self.members.map {|m| {:phone=>m.primary_contact.phone_1, :member=>m}}
#  puts "**** @member_phones=#{@member_phones}"
      msg_statuses.each do |s|
        if s[:id] && s[:phone]
  #        member = Member.find self.members.find_index {|m| m.primary_contact.phone_1 == s[:phone]}
#puts "**** s=#{s}"
          member = @member_phones.find{|m| m[:phone]==s[:phone]}[:member]
#puts "**** member=#{member}"
          sent_message = SentMessage.where(:member_id=>member.id, :message_id=>self.id).first
#puts "**** sent_message.inspect=#{sent_message.inspect}"
          sent_message.update_attributes(
              :gateway_message_id => s[:id], 
              :msg_status=> MessagesHelper::MsgSentToGateway
          )
        end
      end
    # Any sent_messages not now marked with gateway_message_id and msg_status must have errors
    sent_messages.each do |m| 
      m.update_attributes(:msg_status=> MessagesHelper::MsgError) if m.msg_status.nil?
    end
    end
  end
 
  def insert_response_tags
  end
  
  def sending_medium
    unless send_sms or send_email
      errors.add(:base,'Must select a message type (email, SMS, etc.)')
    end
  end
end
