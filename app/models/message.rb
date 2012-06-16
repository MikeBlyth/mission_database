# == Schema Information
# Schema version: 20120609195703
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

  def create_sent_messages
#puts "**** create_sent_messages"
    target_members = Group.members_in_multiple_groups(to_groups_array) & # an array of users
                     Member.those_in_country
    self.members = target_members
#puts "**** target_members=#{target_members}"
#puts "**** target_members.first.primary_contact=#{target_members.first.primary_contact}"
  end
  
  # Send the messages -- done by creating the sent_message objects, one for each member
  #   members_in_multiple_groups(array) is all the members belonging to these groups and
  #   to_groups_array is the array form of the destination groups for this message
  def deliver(params={})
#    puts "**** Message#deliver"
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
    t.strftime('%e%b%I%M%P')[0..9]
  end
  
  def to_groups_array
    to_groups.split(",").map{|g| g.to_i} if to_groups
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
    gateway_reply = 
      sms_gateway.deliver(phone_numbers, self.body[0..149] + ' ' + self.timestamp)
#puts "**** gateway_reply=#{gateway_reply}"
#puts "**** phone_numbers=#{phone_numbers}"
    if phone_number_array.size == 1
      if gateway_reply =~ /ID: (\w+)/
#puts "**** $1=#{$1}"
        gtw_msg_id = $1
        status = MessagesHelper::MsgSentToGateway
      else
        gtw_msg_id = gateway_reply  # Will include error message
#puts "**** gateway_reply=#{gateway_reply}"
      end
puts "**** self.sent_messages=#{self.sent_messages}"
puts "**** sent_messages[0]=#{sent_messages[0]}"     
      self.sent_messages[0].update_attributes(:gateway_message_id => gtw_msg_id, :status=>status)
puts "**** gtw_msg_id=#{gtw_msg_id}"
    end
  end

  def sending_medium
    unless send_sms or send_email
      errors.add(:base,'Must select a message type (email, SMS, etc.)')
    end
  end
end
