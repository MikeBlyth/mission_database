# == Schema Information
# Schema version: 20110413013605
#
# Table name: educations
#
#  id          :integer         not null, primary key
#  description :string(255)
#  code        :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Education < ActiveRecord::Base
include ModelHelper
  include ModelHelper
  before_destroy :check_for_linked_records
  has_many :personnel_data
  validates_presence_of :description, :code
  validates_numericality_of :code, :only_integer => true
  validates_uniqueness_of :code, :description
 
  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end


def cwd
  return self.code_with_description
end
end
