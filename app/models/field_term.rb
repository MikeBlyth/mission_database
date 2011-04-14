# == Schema Information
# Schema version: 20110413013605
#
# Table name: field_terms
#
#  id                       :integer         not null, primary key
#  member_id                :integer
#  employment_status_id     :integer
#  primary_work_location_id :integer
#  ministry_id              :integer
#  start_date               :date
#  end_date                 :date
#  est_start_date           :date
#  est_end_date             :date
#  created_at               :datetime
#  updated_at               :datetime
#

class FieldTerm < ActiveRecord::Base
  include Comperable
  belongs_to :member
  belongs_to :primary_work_location, :class_name => "Location", :foreign_key => "primary_work_location_id"
  belongs_to :employment_status
  belongs_to :ministry

  after_initialize :copy_from_most_recent_term

  def to_label
    "#{start_date || est_start_date}"
  end

  # Compare by date. Since terms may have different sorts of dates available (start, end, 
  # estimated start, estimated end), use some logic to try to make a sensible comparison
  # of which term is "older" or prior to the other. 
  def <=>(other)
      self_start = self.start_date || self.est_start_date
      other_start = other.start_date || other.est_start_date
      return self_start <=> other_start if self_start && other_start
      self_end = self.end_date || self.est_end_date
      other_end = other.end_date || other.est_end_date
      return self_end <=> other_end if self_end && other_end
      return self_start <=> other_end if self_start && other_end
      return self_end <=> other_start if self_end && other_start
      return 0
  end

  def copy_from_most_recent_term
    return unless self.new_record? && !member_id.nil?
    terms = member.field_terms
    return if terms.empty?
    most_recent_term = terms.sort.last
    self.ministry = most_recent_term.ministry
    self.employment_status = most_recent_term.employment_status
    self.primary_work_location = most_recent_term.primary_work_location
  end  

end


