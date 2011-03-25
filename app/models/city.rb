# == Schema Information
# Schema version: 20101221093216
#
# Table name: cities
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  state      :string(255)
#  country    :string(255)     default("NG"), not null
#  created_at :datetime
#  updated_at :datetime
#  latitude   :float
#  longitude  :float
#

class City < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records

  has_many :locations
 # belongs_to :states
  validates_presence_of :name, :country
  validates_presence_of :state,  :if=>:nigeria, :message=>"State required if city is in Nigeria"    
  validates_numericality_of :longitude, :allow_nil => true;
  validates_numericality_of :latitude, :allow_nil => true;
  # note we can't simply check for uniqueness of name since there can be cities w same name

  def locations_sorted
    locations.sort_by {|x| x.description}
  end
  
  def to_s
    self.name
  end

protected

  def nigeria
  #  return false
    c = self.country.to_s.downcase
    return (c == 'nigeria') || (c == 'ng')
  end

end
