# == Schema Information
# Schema version: 20110308202950
#
# Table name: families
#
#  id                    :integer(4)      not null, primary key
#  head_id               :integer(4)
#  status_id             :integer(4)      default(999999)
#  residence_location_id :integer(4)      default(999999)
#  created_at            :datetime
#  updated_at            :datetime
#  last_name             :string(255)
#  first_name            :string(255)
#  middle_name           :string(255)
#  short_name            :string(255)
#  name                  :string(255)
#  sim_id                :string(255)
#  name_override         :boolean(1)
#

class Family < ActiveRecord::Base
  include NameHelper

  attr_accessor :previous_residence_location, :previous_status
  
  belongs_to :head, :class_name => "Member"
  has_many :members, :dependent => :delete_all
      # :delete_all is used so the members will be destroyed without any error checking
  belongs_to :status
  belongs_to :residence_location, :class_name => "Location", :foreign_key => "residence_location_id"
  before_validation :set_indexed_name_if_empty
  validates_presence_of :last_name, :first_name, :name, :status
  validates_uniqueness_of :name, :sim_id, :allow_blank=>true
  validate :name_not_exists

  after_create :create_family_head_member
  after_save   :update_member_locations
  after_save   :update_member_statuses

  def to_label
    "* #{name}"
  end

  def kill_me
    self.update_attributes(:head_id => nil)
    self.members.each {|m| m.destroy}
    self.destroy
  end

  # Copy family residence locations to spouse, head & children, but only when changed.
  # This means that one can individualize locations of members, but individualized values will
  # be overwritten when the family residence location is changed again.
  def update_member_locations
    if self.residence_location != @previous_residence_location
 #     self.members.where("spouse_id > 0 OR child").each {|m| m.update_attribute(:residence_location, self.residence_location)}
      self.members.joins(:family).where('spouse_id > 0 OR child OR members.id = families.head_id').
        update_all("members.residence_location_id = #{self.residence_location_id}")
    end  
  end

  # Copy family status to all family members, but only when changed.
  # This means that one can individualize locations of members, but individualized values will
  # be overwritten when the family status is changed again.
  def update_member_statuses
    if self.status != @previous_status
#      self.members.where("spouse_id > 0 OR child").each {|m| m.update_attribute(:status, self.status)}
      self.members.joins(:family).where('spouse_id > 0 OR child OR members.id = families.head_id').
        update_all("members.status_id = #{self.status_id}")
    end  
  end


  def to_s
    to_label
  end
  
  def full_name
    name
  end

  def casual_name
    head.full_name_short
  end

  # Array of children as Member objects, sorted
  def children
    self.members.where(:child=>true).order("birth_date ASC")
  end
  
  # Array of children's first names sorted oldest to youngest
  def children_names
    names = []
    self.children.each {|child| names << child.first_name}
    return names
  end
  
  # Husband of family as Member object, nil if single
  def husband
    return nil if self.head.spouse.nil?
    return self.head.male? ? self.head : self.head.spouse
  end
  
  # Wife of family as Member object, nil if single
  def wife
    return nil if self.head.spouse.nil?
    return self.head.female? ? self.head : self.head.spouse
  end
  
  # Husband and wife as array of 2 Member.objects, in order
  def couple
    [self.husband, self.wife]
  end
  
  # Creating a new family ==> Need to create the member record for head
  def create_family_head_member
 # debugger
    head = Member.create(:name=>name, :last_name=>last_name, :first_name=>first_name,
            :middle_name => middle_name,
            :status_id=>status_id, :residence_location_id=>residence_location_id, :family =>self, :sex=>'M')
    if ! head.valid?
      errors.add(:head, "Unable to create head of family")
      raise ActiveRecord::Rollback
    end   
    self.update_attributes(:head => head)  # Record newly-created member as the head of family

  end

  # When validating a family, verify on the head-of-family NAME that either
  # * a member with that name exists and is the head-of-family OR
  # * the record is new and the name fields are valid for a new member
  def name_not_exists
    if self.new_record?
      if Member.find_by_name(self.name)
        errors.add(:name, "#{name} already exists for family or member. Modify name to avoid duplication.")
        return false
      else
        return true
      end
    else
      
    end
  end
  
end
