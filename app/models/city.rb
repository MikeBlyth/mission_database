class City < ActiveRecord::Base
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
  
protected

  def nigeria
  #  return false
    c = self.country.to_s.downcase
    return (c == 'nigeria') || (c == 'ng')
  end

end
