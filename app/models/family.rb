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
    head = Member.create!(:name=>name, :last_name=>last_name, :first_name=>first_name,
            :middle_name => middle_name,
            :status=>status, :location=>location, :family =>self)
    self.update_attributes(:head => head)  # Record newly-created member as the head of family
#puts "****** head: #{head.errors}"
  end
  
  def check_for_existing_members
    return self.members.count == 0
  end

end
