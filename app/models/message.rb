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
      
  validates_presence_of :body
  before_save :convert_to_groups
  after_save  :send_messages
  
  def after_initialize
    [:confirm_time_limit, :retries, :retry_interval, :expiration, :response_time_limit, :importance].each do |setting|
      self.send "#{setting}=", Settings.messages[setting] if (self.send setting).nil?
    end
  end    

  def checker
    puts "**** Saving with to_groups=#{to_groups}"
  end
  
  def convert_to_groups
    if to_groups.is_a? Array
    # Convert :to_groups=>["1", "2", "4"] or [1,2,4] to "1,2,4", as maybe simpler than converting with YAML
      to_groups =to_groups.map {|g| g.to_i}.join(",")
    end
  end 
  
  def send_messages
    # Send the messages
    puts "********************************"
    target_groups = to_groups.split(",").map{|g| g.to_i}
    self.members = Group.members_in_multiple_groups(target_groups)
  end
end
