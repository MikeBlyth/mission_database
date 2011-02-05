# == Schema Information
# Schema version: 20101221093216
#
# Table name: locations
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  city_id     :integer(4)      default(-1)
#  created_at  :datetime
#  updated_at  :datetime
#  code        :integer(4)
#

class Location < ActiveRecord::Base
include ModelHelper

  belongs_to :city
  has_many :members
  has_many :families
  has_many :field_terms
  validates_presence_of :description, :code, :city
  validates_uniqueness_of :code, :description
  validates_numericality_of :code, :only_integer => true
  validates_numericality_of :city_id, :only_integer => true

  def to_label
    "#{description}"
  end

  

end
