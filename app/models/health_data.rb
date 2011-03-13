# == Schema Information
# Schema version: 20110312214702
#
# Table name: health_data
#
#  id           :integer(4)      not null, primary key
#  member_id    :integer(4)
#  bloodtype_id :integer(4)
#  current_meds :string(255)
#  issues       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  allergies    :string(255)
#

class HealthData < ActiveRecord::Base
  belongs_to :member, :autosave => true
  belongs_to :bloodtype
end
