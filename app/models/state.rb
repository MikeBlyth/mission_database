class State < ActiveRecord::Base
 validates_presence_of :name
 validates_uniqueness_of :name

  def to_label
    "#{name}"
  end

end
