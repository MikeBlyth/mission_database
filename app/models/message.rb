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
include MessagesHelper

class Message < ActiveRecord::Base
  has_many :sent_messages
  has_many :members, :through => :sent_messages  # May not be needed, 
  belongs_to :user
  validates_numericality_of :confirm_time_limit, :retries, :retry_interval, 
      :expiration, :response_time_limit, :importance, :allow_nil => true
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
    save! if self.new_record?
    if send_email
      email_addresses = members.map {|m| m.primary_contact.email_1}
      deliver_email(email_addresses)
    end
    if send_sms
      phone_numbers = members.map do |m| 
        this_contact = m.primary_contact
        this_phone = this_contact.phone_1 || this_contact.phone_2  # in case there is _2 and not _1
        this_phone.gsub('+','') if this_phone   # don't want the plus signs on Clickatell
      end
      phone_numbers.compact   # remove entries that don't have phone numbers
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
      str = (t.strftime('%e%b')+t.strftime('%l')[1]+t.strftime(':%M%P'))[0..9]
    else
      str = t.strftime('%e%b%l%M%P')[0..9]
    end
    str = str[1..9] if str[0] == ' '   # gives us one extra character :-)
    return str
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

  # Do whatever needed to record that 'member' has responded to this message
  # Do not update a record that already has been marked with MessagesHelper::MsgResponseReceived
  def process_response(params={})
    member=params[:member]
    text=params[:text]
    mode=params[:mode] # (SMS or email)
  puts "**** process_response: self.id=#{self.id}, member=#{member}, text=#{text}"
#puts "**** sent_messages = #{self.sent_messages}"
    sent_message = self.sent_messages.detect {|m| m.member_id == member.id}
#puts "**** sent_message=#{sent_message}"
    if sent_message && (sent_message.msg_status.nil? || sent_message.msg_status < MessagesHelper::MsgResponseReceived ) 
      sent_message.update_attributes(:msg_status=>MessagesHelper::MsgResponseReceived,
          :confirmation_message=>text, :confirmed_time => Time.now)
    else
      AppLog.create(:code => "Message.response", 
        :description=>"Message#process_response called with #{params}, but corresponding sent_message record was not found", :severity=>'error')
    end
  end

#private

  # ToDo: clean up this mess and just give Notifier the Message object!
  def deliver_email(emails)
#puts "**** deliver_email: emails=#{emails}"
    self.subject ||= 'Message from SIM Nigeria'
    outgoing = Notifier.send_group_message(:recipients=>emails, :content=>self.body, 
        :subject => subject, :id => id, :response_time_limit => response_time_limit, 
        :bcc => true) # send using bcc:, not to:
raise "send_email with nil email produced" if outgoing.nil?
    outgoing.deliver
  end
  
  def assemble_body
    resp_tag = response_time_limit? ? " !#{self.id}" : ''
    self.body = body[0..(159-self.timestamp.size-resp_tag.size)] + resp_tag + ' ' + self.timestamp
  end

  def deliver_sms(params)
    sms_gateway = params[:sms_gateway]
    phone_number_array = params[:phone_numbers]
    phone_numbers = phone_number_array.join(',')
#puts "**** sms_gateway.deliver=#{sms_gateway.deliver}"
    assemble_body()
    gateway_reply = 
      sms_gateway.deliver(phone_numbers, body)
#puts "**** gateway_reply=#{gateway_reply}, match=#{gateway_reply =~ /ID: (\w+)/}, $1=#{$1}"      
#puts "**** gateway_reply=#{gateway_reply}"
#match = gateway_reply =~ /ID: (\w+)/
#msg_id = $1
#puts "**** match=#{match}, msg_id ($1) = #{$1}"
# Gives gateway_reply=ID: f6ce4d001b13842cce12e1486e0ac926, match=0, $1=  in heroku, but
#       gateway_reply=ID: be407fdfc611df569776bf660d5f484a, match=0, $1=be407fdfc611df569776bf660d5f484a
# in Rails console. 
#puts "**** phone_numbers=#{phone_numbers}"
    ######## SINGLE PHONE NUMBER ########
    gtw_msg_id = nil
    if phone_number_array.size == 1
      if gateway_reply =~ /ID: (\w+)/
        gtw_msg_id = $1
        gtw_msg_id = gateway_reply[4..99]        # Temporary workaround as $1 doesn't work on Heroku
        msg_status = MessagesHelper::MsgSentToGateway
#puts "**** msg_status=#{msg_status}, gtw_msg_id=#{gtw_msg_id}"
      else
        gtw_msg_id = gateway_reply  # Will include error message
        msg_status = MessagesHelper::MsgError
#puts "**** Error: gtw_msg_id=#{gtw_msg_id}, msg_status=#{msg_status}"
      end
#puts "**** updating id=#{sent_messages[0].id}, gtw_msg_id=#{gtw_msg_id}"
      self.sent_messages[0].update_attributes(
          :gateway_message_id => gtw_msg_id, 
          :msg_status=>msg_status
          )
#puts "**** self.sent_messages[0].reload.gateway_message_id=#{self.sent_messages[0].reload.gateway_message_id}"          
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
 
  def sending_medium
    unless send_sms or send_email
      errors.add(:base,'Must select a message type (email, SMS, etc.)')
    end
  end
end
