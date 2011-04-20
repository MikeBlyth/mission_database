# == Schema Information
# Schema version: 20110420075727
#
# Table name: scheduled_updates
#
#  id          :integer         not null, primary key
#  action_date :date
#  member_id   :integer
#  family_id   :integer
#  change_type :string(255)
#  old_value   :string(255)
#  new_value   :string(255)
#  status      :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ScheduledUpdate < ActiveRecord::Base
  belongs_to :member
  belongs_to :family
  validates_presence_of :action_date, :new_value
  validate :future_date
  validate :member_exists
  validate :family_exists
  before_save :setup

private
    
  def future_date
    if self.action_date && (self.action_date < Date.today)
      errors.add(:date, "must be in future")
    end
  end

  def member_exists
    errors.add(:member, 'does not exist in database') if self.member_id && !self.member
  end
    
  def family_exists
    errors.add(:family, 'does not exist in database') if self.family_id && !self.family
  end
  
  def status_code_exists
    errors.add(:new_value, 'not an existing status code') unless
      Status.find_by_code(new_value)
  end    
  
  def setup
    self.status = 'pending'
  end
    
end

class ScheduledUpdateMemberStatus < ScheduledUpdate
  validates_presence_of :member_id
  validate :status_code_exists  # Validate the new_value to be assigned is valid status code
  
  before_save :setup
  
  def setup
    super
    self.old_value =  self.member.status ? self.member.status.code : 'nil'
  end
  
end 
