class ContactType < ActiveRecord::Base
include ModelHelper
  has_many :contacts
  validates_uniqueness_of :code, :description

  def to_label
    "#{description}"
  end

end
