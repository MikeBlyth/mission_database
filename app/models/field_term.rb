# == Schema Information
# Schema version: 20120518075102
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
#  created_at               :datetime
#  updated_at               :datetime
#  beginning_travel_id      :integer
#  ending_travel_id         :integer
#  end_estimated            :boolean
#  start_estimated          :boolean
#

class FieldTerm < ActiveRecord::Base
  include Comparable
  belongs_to :member
  belongs_to :primary_work_location, :class_name => "Location", :foreign_key => "primary_work_location_id"
  belongs_to :employment_status
  belongs_to :ministry
  belongs_to :beginning_travel, :class_name => "Travel"
  belongs_to :ending_travel, :class_name => "Travel"
  belongs_to :spouse, :class_name => "Member", :foreign_key => "spouse_id"

  after_initialize :copy_from_most_recent_term

  def to_label
    "#{start_date}"
  end

  # Compare by date. Since terms may have different sorts of dates available (start, end, 
  # estimated start, estimated end), use some logic to try to make a sensible comparison
  # of which term is "older" or prior to the other. 
  def <=>(other)
      self_start = self.start_date
      other_start = other.start_date
      self_end = self.end_date 
      other_end = other.end_date
      return self_start <=> other_start if self_start && other_start
      return self_end <=> other_end if self_end && other_end
      return self_start <=> other_end if self_start && other_end
      return self_end <=> other_start if self_end && other_start
      return 0
  end

  def name
    member.name
  end

  # String reporting the start & end dates
  def dates
    start_s = start_date ? start_date.to_s : '?'
    end_s = end_date ? end_date.to_s : '?'
    "#{start_s} to #{end_s}"
  end

  def future?
    start_date && start_date > Date.today ||
    end_date && end_date > Date.today + 4.years
  end
  
  def past?
    end_date && end_date < Date.today ||
    start_date && start_date < Date.today-4.years
  end
  
  def current?
    if start_date && end_date
      return ( start_date <= Date.today && end_date >= Date.today )
    end
    if start_date
      # Assume that terms starting more than 4 years ago are not current even if no end date is present
      return ( start_date <= Date.today && start_date > Date.today-4.years )
    end
    if end_date
      return (end_date >= Date.today && end_date < Date.today+4.years)
    end
    return false
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


