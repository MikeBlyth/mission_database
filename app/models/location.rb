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
