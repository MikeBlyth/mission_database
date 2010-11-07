class Ministry < ActiveRecord::Base
include ModelHelper
  has_many :members
  has_many :terms
  validates_uniqueness_of :code, :description
  validates_presence_of :code, :description

  def to_label
    "#{description}"
  end



end
