# == Schema Information
# Schema version: 20110213084018
#
# Table name: locations
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  city_id     :integer(4)      default(999999)
#  created_at  :datetime
#  updated_at  :datetime
#  code        :integer(4)
#

class Location < ActiveRecord::Base
include ModelHelper

  belongs_to :city
  has_many :members, :foreign_key => "residence_location_id"
  has_many :families, :foreign_key => "residence_location_id"
  has_many :field_terms, :foreign_key => "primary_work_location_id"
  validates_presence_of :description, :code, :city
  validates_uniqueness_of :code, :description
  validates_numericality_of :code, :only_integer => true

  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end

  

end
