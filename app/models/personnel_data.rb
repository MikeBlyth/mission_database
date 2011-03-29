# == Schema Information
# Schema version: 20110329162620
#
# Table name: personnel_data
#
#  id                   :integer(4)      not null, primary key
#  member_id            :integer(4)
#  qualifications       :string(255)
#  comments             :string(255)
#  employment_status_id :integer(4)
#  education_id         :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#  date_active          :date
#  est_end_of_service   :date
#

class PersonnelData < ActiveRecord::Base
 belongs_to :member, :autosave => true
 belongs_to :education
 belongs_to :employment_status
end
