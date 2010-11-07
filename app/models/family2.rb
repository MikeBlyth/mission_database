class Family < ActiveRecord::Base

  has_many :members
  belongs_to :status
  belongs_to :location
  
  def to_label
    "#{full}"
  end
end
