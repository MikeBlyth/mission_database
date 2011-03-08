# == Schema Information
# Schema version: 20110308202950
#
# Table name: field_terms
#
#  id                       :integer(4)      not null, primary key
#  member_id                :integer(4)
#  primary_work_location_id :integer(4)      default(999999)
#  ministry_id              :integer(4)      default(999999)
#  start_date               :date
#  end_date                 :date
#  est_start_date           :date
#  est_end_date             :date
#  created_at               :datetime
#  updated_at               :datetime
#  employment_status_id     :integer(4)      default(999999)
#

class FieldTerm < ActiveRecord::Base
  belongs_to :member
  belongs_to :primary_work_location, :class_name => "Location", :foreign_key => "primary_work_location_id"
  belongs_to :employment_status
  belongs_to :ministry

  def to_label
    "#{start_date || est_start_date}"
  end

end
