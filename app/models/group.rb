# == Schema Information
# Schema version: 20120624072326
#
# Table name: groups
#
#  id              :integer         not null, primary key
#  group_name      :string(255)
#  type_of_group   :string(255)
#  parent_group_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  abbrev          :string(255)
#  primary         :boolean
#

class Group < ActiveRecord::Base
  extend ExportHelper

  has_and_belongs_to_many :members
  belongs_to :parent_group, :class_name => "Group", :foreign_key => "parent_group_id"
  has_many :subgroups, :class_name => "Group", :foreign_key => "parent_group_id"
  validate :abbrev_ok
  validates_presence_of :group_name, :abbrev
  validates_uniqueness_of :group_name, :abbrev
  
  def to_s
    group_name
  end

  # Return a list of all the members who are in this group *or* its subgroups.
  def members_with_subgroups
    belong = self.member_ids
    self.subgroups.each do |sub|
      belong << sub.members_with_subgroups
    end
    return belong.uniq.flatten
  end

  # Given an array of group names, return an array of matching group ids
  # If a name does not correspond to a group, return the name itself in the results
  # so calling method must check for string vs. integer to detect this error condition.
  def self.ids_from_names(names)
    names.map do |name|
      group = Group.find(:first, 
        :conditions => [ "lower(group_name) = ? OR lower(abbrev) = ?", name.downcase, name.downcase])
      group.nil? ? name : group.id
    end
  end

  # Return array of member_ids who belong to any group (or its subgroups) in an array of group_ids
  # E.g. if there are groups with ids = 1,2,3,4 ...
  # Group.members_in_multiple_groups([1,3]) will return all the members who belong to group 1 (or subgroups) or 
  # group 3 (or subgroups). Group_ids which do not exist in the database are ignored. 
  def self.members_in_multiple_groups(group_ids)
    return [] if (group_ids || []) == []
    members = []  # This is an array of member ids
    group_ids.each do |group_id|
      group = Group.find_by_id group_id
      members << group.members_with_subgroups if group
    end
    member_records = Member.where(:id=>members.flatten.uniq.sort)
    return member_records.joins(:contacts).where(:contacts=>{:is_primary => true}).all
  end

  def abbrev_ok
    abbrev = group_name[0..5].sub(' ','').downcase if abbrev.blank?
    errors.add(:abbrev,'must not include spaces') if abbrev =~ / /
  end
  
  def self.primary_group_abbrevs
     self.where(:primary=>true).map {|g| g.abbrev}.join(' ')
  end

    
end
