# == Schema Information
# Schema version: 20110501073902
#
# Table name: personnel_data
#
#  id                   :integer         not null, primary key
#  member_id            :integer
#  qualifications       :string(255)
#  comments             :string(255)
#  employment_status_id :integer
#  education_id         :integer
#  created_at           :datetime
#  updated_at           :datetime
#  date_active          :date
#  est_end_of_service   :date
#  end_nigeria_service  :date
#

class PersonnelData < ActiveRecord::Base
 belongs_to :member, :autosave => true
 belongs_to :education
 belongs_to :employment_status
end
