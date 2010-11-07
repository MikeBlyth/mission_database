class Bloodtype < ActiveRecord::Base

  has_many :members
  validates_uniqueness_of :full
  def to_label
    "#{full}"
  end
end
