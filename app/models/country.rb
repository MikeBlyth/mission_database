class Country < ActiveRecord::Base
  validates_presence_of :name, :nationality
  validates_uniqueness_of :code, :name
  has_many :members
  
  def to_label
    "#{name}"
  end

  def name_utf
    self.name.force_encoding('utf-8')
  end

  def nationality_utf
    self.nationality.force_encoding('utf-8')
  end

  def self.choices
    return Country.find(:all, :order => :name, :conditions=> 'include_in_selection = TRUE')
  end
  def self.countryname(ccode)
    return Country.find(:first, :conditions=> "code = '#{ccode}'").name
  end
end
