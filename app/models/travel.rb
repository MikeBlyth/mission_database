# == Schema Information
# Schema version: 20110307141121
#
# Table name: travels
#
#  id               :integer(4)      not null, primary key
#  date             :date
#  purpose          :string(255)
#  return_date      :date
#  flight           :string(255)
#  member_id        :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  origin           :string(255)
#  destination      :string(255)
#  guesthouse       :string(255)
#  baggage          :integer(4)
#  total_passengers :integer(4)
#  confirmed        :date
#  other_travelers  :string(255)
#  with_spouse      :boolean(1)
#  with_children    :boolean(1)
#  arrival          :boolean(1)
#

class Travel < ActiveRecord::Base
#  has_and_belongs_to_many :members
  belongs_to :member
 validates_presence_of :date

  def to_label
    "#{date.to_s} #{flight}"
  end

end
