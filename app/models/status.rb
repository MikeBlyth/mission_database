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

  # Class method Status.field_statuses and Status.active_statuses
  # Likely won't need these but just use joins instead.
  # Return array of status_ids for statuses marked as "on_field"
  #   (i.e. if a member or family has this status, the member or family is considered 
  #   to be on the field)
  def self.field_statuses
    selected = self.where(:on_field=>true)
    ids = selected.map {|x| x.id}
    return ids
  end
  
  # Like field_statuses above
  def self.active_statuses
    selected = self.where(:active=>true)
    ids = selected.map {|x| x.id}
    return ids
  end
  

  def to_label
    self.to_s
  end
  
  def to_s
    self.description
  end

end
