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
  has_many :subgroups, :class_name => "Group"
  validates_uniqueness_of :group_name
  
  def to_s
    group_name
  end
end
