# == Schema Information
# Schema version: 20120607065210
#
# Table name: groups
#
#  id              :integer         not null, primary key
#  group_name      :string(255)
#  type_of_group   :string(255)
#  parent_group_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class Group < ActiveRecord::Base
  has_and_belongs_to_many :members
  belongs_to :parent_group, :class_name => "Group", :foreign_key => "parent_group_id"
  has_many :subgroups, :class_name => "Group", :foreign_key => "parent_group_id"
  validates_uniqueness_of :group_name
  
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

  # Return array of member_ids who belong to any group (or its subgroups) in an array of group_ids
  # E.g. if there are groups with ids = 1,2,3,4 ...
  # Group.members_in_multiple_groups([1,3]) will return all the members who belong to group 1 (or subgroups) or 
  # group 3 (or subgroups). Group_ids which do not exist in the database are ignored. 
  def self.members_in_multiple_groups(group_ids=[])
    members = []
    group_ids.each do |group_id|
      group = Group.find_by_id group_id
      members << group.members_with_subgroups if group
    end
    return Member.find members.flatten.uniq
  end
end
