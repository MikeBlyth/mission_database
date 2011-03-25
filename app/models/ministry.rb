# == Schema Information
# Schema version: 20101221093216
#
# Table name: ministries
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  code        :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class Ministry < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records
  has_many :members
  has_many :field_terms
  validates_uniqueness_of :code, :description
  validates_presence_of :code, :description

  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end



end
