# == Schema Information
# Schema version: 20110413013605
#
# Table name: locations
#
#  id          :integer         not null, primary key
#  description :string(255)
#  city_id     :integer         default(999999)
#  created_at  :datetime
#  updated_at  :datetime
#  code        :integer
#

class Location < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records

  belongs_to :city
#*  has_many :residence_members, :class_name=>'Member', :foreign_key => "residence_location_id"
  has_many :work_members, :class_name=>'Member', :foreign_key => "work_location_id"
  has_many :families, :foreign_key => "residence_location_id"
  has_many :field_terms, :foreign_key => "primary_work_location_id"
  validates_presence_of :description, :code
  validates_uniqueness_of :code, :description
  validates_numericality_of :code, :only_integer => true

  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end

  

end
