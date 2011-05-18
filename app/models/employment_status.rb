# == Schema Information
# Schema version: 20110518071651
#
# Table name: employment_statuses
#
#  id          :integer         not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  mk_default  :boolean
#  umbrella    :boolean
#  org_member  :boolean         default(TRUE)
#  current_use :boolean         default(TRUE)
#

class EmploymentStatus < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records
  has_many :personnel_data
  has_many :field_terms

  validates_presence_of :description, :code
  validates_uniqueness_of :code, :description

  def self.org_statuses   # These are employment statuses that classify the person as a member (employee)
    statuses = self.where("org_member")
    return statuses.map {|s| s.id}
  end

  # These are employment statuses that classify the person as under the org's umbrella but not a member (employee)
  def self.umbrella_statuses
    statuses = self.where("umbrella")
    return statuses.map {|s| s.id}
  end

  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end



end
