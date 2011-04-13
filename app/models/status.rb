# == Schema Information
# Schema version: 20110413013605
#
# Table name: statuses
#
#  id          :integer         not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  active      :boolean
#  on_field    :boolean
#

class Status < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records
  has_many :members
  has_many :families
  validates_uniqueness_of :code, :description
  validates_presence_of :code, :description

  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end

end
