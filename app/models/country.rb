class Country < ActiveRecord::Base
  validates_presence_of :name, :nationality
  validates_uniqueness_of :code, :name
  has_many :members

  def to_label
    "#{name}"
  end

  def self.find(id, options={})
    x = super id
    x.nationality = x.nationality.force_encoding("UTF-8")
    x
  end

  def name_utf
puts "Name_UTF for #{self.name}"
    self.name.force_encoding('utf-8')
  end

  def nationality_utf
puts "Nationality_UTF for #{self.name}"    
    self.nationality.force_encoding('utf-8')
  end

  def self.choices
    return Country.find(:all, :order => :name, :conditions=> 'include_in_selection = TRUE')
  end
  def self.countryname(ccode)
    return Country.find(:first, :conditions=> "code = '#{ccode}'").name
  end
end
