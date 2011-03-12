# == Schema Information
# Schema version: 20110312214702
#
# Table name: personnel_data
#
#  id                   :integer(4)      not null, primary key
#  member_id            :integer(4)
#  qualifications       :string(255)
#  education_id         :integer(4)
#  employment_status_id :integer(4)
#  date_active          :date
#  comments             :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

class PersonnelData < ActiveRecord::Base
 belongs_to :member
 belongs_to :education
 belongs_to :employment_status
end
