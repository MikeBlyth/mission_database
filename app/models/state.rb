# == Schema Information
# Schema version: 20101221093216
#
# Table name: states
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  zone       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class State < ActiveRecord::Base
 validates_presence_of :name
 validates_uniqueness_of :name

  def to_label
    "#{name}"
  end

end
