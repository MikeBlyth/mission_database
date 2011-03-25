# == Schema Information
# Schema version: 20101221093216
#
# Table name: contact_types
#
#  id          :integer(4)      not null, primary key
#  code        :integer(4)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ContactType < ActiveRecord::Base
include ModelHelper
  include ModelHelper
  before_destroy :check_for_linked_records
  has_many :contacts
  validates_uniqueness_of :code, :description

  def to_label
    "#{description}"
  end

end
