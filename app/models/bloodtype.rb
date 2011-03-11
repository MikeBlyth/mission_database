# == Schema Information
# Schema version: 20101221093216
#
# Table name: bloodtypes
#
#  id         :integer(4)      not null, primary key
#  abo        :string(255)
#  rh         :string(255)
#  comment    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  full       :string(255)
#

class Bloodtype < ActiveRecord::Base

  has_many :members
  has_many :health_data
  validates_uniqueness_of :full
  def to_label
    "#{full}"
  end
end
