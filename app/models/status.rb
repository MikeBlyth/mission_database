# == Schema Information
# Schema version: 20101221093216
#
# Table name: statuses
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  active      :boolean(1)
#  on_field    :boolean(1)
#

class Status < ActiveRecord::Base
  has_many :members
  has_many :families
  has_many :field_terms
  validates_uniqueness_of :code, :description
  validates_presence_of :code, :description

  def to_label
    "#{description}"
  end

end
