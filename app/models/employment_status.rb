# == Schema Information
# Schema version: 20110413013605
#
# Table name: employment_statuses
#
#  id          :integer         not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  mk_default  :boolean
#

class EmploymentStatus < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records
  has_many :personnel_data
  has_many :field_terms

  validates_presence_of :description, :code
  validates_uniqueness_of :code, :description

  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end



end
