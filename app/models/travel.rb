class Travel < ActiveRecord::Base
#  has_and_belongs_to_many :members
  belongs_to :member
 validates_presence_of :date

  def to_label
    "#{date.to_s} #{flight}"
  end

end
