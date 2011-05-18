# == Schema Information
# Schema version: 20110413013605
#
# Table name: countries
#
#  id                   :integer         not null, primary key
#  code                 :string(255)
#  name                 :string(255)
#  nationality          :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  include_in_selection :boolean
#

class Country < ActiveRecord::Base
  include ModelHelper
  before_destroy :check_for_linked_records
  validates_presence_of :name, :nationality
  validates_uniqueness_of :code, :name
  has_many :members

  def to_label
    self.name
  end
  def to_s
    self.name
  end
  def description
    self.name
  end

  def self.choices
    return Country.find(:all, :order => :name, :conditions=> 'include_in_selection = TRUE')
  end

  def self.countryname(ccode)
    return Country.find(:first, :conditions=> "code = '#{ccode}'").name
  end
end
