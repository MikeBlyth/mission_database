# == Schema Information
# Schema version: 20110213084018
#
# Table name: families
#
#  id            :integer(4)      not null, primary key
#  head_id       :integer(4)
#  status_id     :integer(4)      default(999999)
#  location_id   :integer(4)      default(999999)
#  created_at    :datetime
#  updated_at    :datetime
#  last_name     :string(255)
#  first_name    :string(255)
#  middle_name   :string(255)
#  short_name    :string(255)
#  name          :string(255)
#  sim_id        :string(255)
#  name_override :boolean(1)
#

class Family < ActiveRecord::Base
  include NameHelper
  
  belongs_to :head, :class_name => "Member"
  has_many :members, :dependent => :delete_all
      # :delete_all is used so the members will be destroyed without any error checking
  belongs_to :status
  belongs_to :location
  before_validation :set_indexed_name_if_empty
  validates_presence_of :last_name, :first_name, :name
  validates_uniqueness_of :name, :sim_id, :allow_blank=>true

  after_create :create_family_head_member

  def to_label
    "* #{name}"
  end

  def kill_me
    self.update_attributes(:head_id => nil)
    self.members.each {|m| m.destroy}
    self.destroy
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
            :status=>status, :location=>location, :family =>self, :sex=>'M')
    self.update_attributes(:head => head)  # Record newly-created member as the head of family
  end
  
end
