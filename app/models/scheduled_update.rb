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
  include ApplicationHelper

  belongs_to :member
  belongs_to :family
  validates_presence_of :action_date, :new_value
#  validate :future_date
  validate :member_exists
  validate :family_exists
  before_create :setup


private
    
  def future_date
    if self.action_date && (self.action_date < Date.today)
      errors.add(:date, "must be in future")
    end
  end

  def member_exists
    errors.add(:member, 'does not exist in database') if (self.status =~ /error/ ).nil? && 
                                                          self.member_id && !self.member
  end
    
  def family_exists
    errors.add(:family, 'does not exist in database') if self.family_id && !self.family
  end
  
  def status_code_exists
    errors.add(:new_value, 'not an existing status code') unless
      self.status =~ /error/ ||
      Status.find_by_code(new_value)
  end    
  
  def setup
    self.status ||= 'pending'
  end
  
  def execute
    self.save!
  end
    
end

class ScheduledUpdateMemberStatus < ScheduledUpdate
  #validates_presence_of :member_id
  validate :status_code_exists  # Validate the new_value to be assigned is valid status code
  
  before_create :setup
  
  def setup
    super
    self.old_value =  self.member.status ? self.member.status.code : 'nil'
  end
  
  def execute
    return unless status == 'pending'
    errors = []
    errors << "error: member not found" if !self.member
    new_status = Status.find_by_code(new_value)
    errors << "error: new status #{new_value} not found" if new_status.nil?
    if errors.empty?
      self.member.update_attribute(:status, new_status)
      self.status = 'finished'
    else
      self.status = smart_join(errors, '; ')  
    end
    super
  end # execute
  
end 
