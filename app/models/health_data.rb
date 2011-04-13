# == Schema Information
# Schema version: 20110413013605
#
# Table name: health_data
#
#  id           :integer         not null, primary key
#  member_id    :integer
#  bloodtype_id :integer
#  current_meds :string(255)
#  issues       :string(255)
#  allergies    :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class HealthData < ActiveRecord::Base
  belongs_to :member, :autosave => true
  belongs_to :bloodtype
end
