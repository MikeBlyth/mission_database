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
  belongs_to :head, :class_name => "Member"
  has_many :members
  belongs_to :status
  belongs_to :location
  validates_presence_of :last_name, :first_name, :name
  validates_uniqueness_of :name, :sim_id, :allow_blank=>true


  after_create :create_family_head_member
  before_destroy :check_for_existing_members
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

  # Creating a new family ==> Need to create the member record for head
  def create_family_head_member
 # debugger
    head = Member.create(:name=>name, :last_name=>last_name, :first_name=>first_name,
            :middle_name => middle_name,
            :status=>status, :location=>location, :family =>self)
    self.update_attributes(:head => head)  # Record newly-created member as the head of family
  end
  
  def check_for_existing_members
    return self.members.count == 0
  end

end
