# == Schema Information
# Schema version: 20110413013605
#
# Table name: contact_types
#
#  id          :integer         not null, primary key
#  code        :integer
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ContactType < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records
  has_many :contacts
  validates_uniqueness_of :code, :description

  def to_label
    "#{description}"
  end

end
