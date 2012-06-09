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
  before_save :checker
  
  def checker
    puts "**** Saving with to_groups=#{to_groups}"
  end
end
