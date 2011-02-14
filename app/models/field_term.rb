# == Schema Information
# Schema version: 20110213084018
#
# Table name: field_terms
#
#  id                   :integer(4)      not null, primary key
#  member_id            :integer(4)
#  location_id          :integer(4)      default(999999)
#  ministry_id          :integer(4)      default(999999)
#  start_date           :date
#  end_date             :date
#  est_start_date       :date
#  est_end_date         :date
#  created_at           :datetime
#  updated_at           :datetime
#  employment_status_id :integer(4)      default(999999)
#

class FieldTerm < ActiveRecord::Base
  belongs_to :member
  belongs_to :location
  belongs_to :employment_status
  belongs_to :ministry

  def to_label
    "#{start_date || est_start_date}"
  end

end
