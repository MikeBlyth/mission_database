# == Schema Information
# Schema version: 20110413013605
#
# Table name: states
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  zone       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class State < ActiveRecord::Base
 validates_presence_of :name
 validates_uniqueness_of :name

  def to_label
    self.to_s
  end
  
  def to_s
    self.name
  end


end
