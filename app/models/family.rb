# == Schema Information
# Schema version: 20120522145318
#
# Table name: families
#
#  id                    :integer         not null, primary key
#  head_id               :integer
#  status_id             :integer
#  residence_location_id :integer
#  created_at            :datetime
#  updated_at            :datetime
#  last_name             :string(255)
#  first_name            :string(255)
#  middle_name           :string(255)
#  short_name            :string(255)
#  name                  :string(255)
#  name_override         :boolean
#  sim_id                :string(255)
#  summary_sent          :date
#  tasks                 :string(255)
#

class Family < ActiveRecord::Base
  include NameHelper
  include FilterByStatusHelper
  include ApplicationHelper
  extend ExportHelper

  attr_accessor :previous_residence_location, :previous_status
  
  belongs_to :head, :class_name => "Member"
  has_many :members, :dependent => :delete_all
      # :delete_all is used so the members will be destroyed without any error checking
  belongs_to :status
  belongs_to :residence_location, :class_name => "Location", :foreign_key => "residence_location_id"
  before_validation :set_indexed_name_if_empty
  validates_presence_of :name
#  validates_presence_of :last_name, :first_name, :name
  validates_uniqueness_of :name, :sim_id, :allow_blank=>true
  validate :name_not_exists

 # after_create :create_family_head_member
  after_save   :update_member_locations
  before_save   :update_member_statuses

  def to_label
    "#{name}"
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
#    if self.residence_location != @previous_residence_location
#      self.members.where("spouse_id > 0 OR child OR id = ?", self.head_id).each {|m| m.update_attribute(:residence_location, self.residence_location)}
# #     self.members.joins(:family).where('spouse_id > 0 OR child OR members.id = families.head_id').
# #       update_all("members.residence_location_id = #{self.residence_location_id}")
#    end  
  end

  # Copy family status to all family members, but only when changed.
  # This means that one can individualize locations of members, but individualized values will
  # be overwritten when the family status is changed again.
  def update_member_statuses
    if self.changed_attributes.has_key?('status_id')
      self.dependents.each {|m| m.update_attribute(:status, self.status)}
    end  
  end

  def dependents
    self.members.delete_if {|m| (not m.dependent)}
  end  

  def self.those_umbrella
    umbrella_members = Member.those_umbrella.map {|u| u.id}  # Generate array of ids of all 'umbrella members'
    self.where("head_id in (?)", umbrella_members)
  end

  def <=>(other)
    self.name <=> other.name
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
#  def children
#    self.members.where(:child=>true).order("birth_date ASC")
#    self.head.children
#  end

  def children(include_grown=false)
    age_cutoff = include_grown ? 999 : 19  # 
    birthdate_cutoff = Date::today() - age_cutoff.years
    self.members.where("(birth_date IS ? OR birth_date > ?) AND child", nil, birthdate_cutoff).
      order("birth_date ASC")
  end

  
  # Array of children's first names sorted oldest to youngest
  def children_names
    names = []
    self.children.each {|child| names << child.short}
    return names
  end
  
  # Takes a param hash for new member record and creates a child in this family
  def add_child(params)
#puts "**** add_child: params=#{params}, \nself=#{self.attributes}"
    pers_data = params.delete(:personnel_data)
    child = Member.new({:last_name=>self.head.last_name, :family=>self, 
                            :child=>true,
                            :country=>self.head.country,
#*                            :residence_location=>self.residence_location
                            }.merge params
                            )
    if child.save
      child.personnel_data.update_attributes(pers_data)
    end
    return child
  end                            
                            
  # Husband of family as Member object, nil if single
  def husband
    return nil if self.head.nil? || self.head.spouse.nil?
    return self.head.male? ? self.head : self.head.spouse
  end
  
  # Wife of family as Member object, nil if single
  def wife
    return nil if self.head.nil? || self.head.spouse.nil?
    return self.head.female? ? self.head : self.head.spouse
  end
  
  # Husband and wife as array of 2 Member.objects, in order
  def couple
    [self.husband, self.wife]
  end
 
  def married_couple?
    ! head.spouse.nil?
  end 

  def spouse
    head.spouse
  end
  
  def employment_status
    head.employment_status
  end
  
 # Creating a new family ==> Need to create the member record for head
  def create_family_head
    head = Member.create(:name=>name, :last_name=>last_name, :first_name=>first_name,
            :middle_name => middle_name,
            :status_id=>status_id, 
            :residence_location_id=>residence_location_id, 
            :family =>self, 
            :sex=>'M')
    if !head.valid?
      errors.add(:head, "Unable to create head of family")
      raise ActiveRecord::Rollback
    end   
    self.update_attributes(:head => head)  # Record newly-created member as the head of family
    return head
  end

  # Like member current location, and will be the same if both spouses have same current_location,
  # Otherwise, give separately for spouses.
  def current_location_hash(options={})
    head_current_location_hash = head.current_location_hash
    return head_current_location_hash unless married_couple?    # If single, just use head's current_location_hash
    spouse_current_location_hash = spouse.current_location_hash
#    if head_current_location_hash == spouse_current_location_hash  # if identical, use 1
#      return pluralize_verbs(head_current_location_hash) 
#    else
#      return current_locations_merged_hash
#    end
    return current_locations_merged_hash
  end 

  def current_location(options={:with_residence=>true, :with_work=>true})
    cur_loc_hash = current_location_hash(options)
    answer = options[:with_residence] ? cur_loc_hash[:residence]  : ' '
    if  options[:with_work] && 
        !cur_loc_hash[:work].blank? && 
        (cur_loc_hash[:work] != cur_loc_hash[:residence])
      answer += " (#{cur_loc_hash[:work]})" 
    end
    answer += " (#{cur_loc_hash[:travel]})" if !cur_loc_hash[:travel].blank?
    answer += " (#{cur_loc_hash[:temp]})" if !cur_loc_hash[:temp].blank?
    answer += " (#{cur_loc_hash[:reported_location]})" if !cur_loc_hash[:reported_location].blank?
    return answer
  end

  # Primary email of the family head, if there is a contact record & email. Nil otherwise.
  def email
    c = self.head.primary_contact 
    c ? c.email_1 : nil
  end

  # When validating a family, verify on the head-of-family NAME that either
  # * a member with that name exists and is the head-of-family OR
  # * the record is new and the name fields are valid for a new member
  def name_not_exists
    if self.new_record?
      if Member.find_by_name(self.name)
        errors.add(:name, "There is already a member named #{name}. Modify name to avoid duplication.")
        return false
      else
        return true
      end
    end
  end

  # Access some data from the head-of-family, so e.g. family.date_active is same as family.head.date_active
  def date_active 
    self.head.date_active
  end

  def est_end_of_service 
    self.head.est_end_of_service
  end

  def employment_status 
    self.head.employment_status
  end

  def most_recent_term 
    self.head.most_recent_term
  end

  def pending_term
    self.head.pending_term
  end

private

  def pluralize_verbs(s)
    s.sub(/returns /,'return ').sub(/arrives /, 'arrive ') if s
  end

  def merge_one_location_param(h, w, param)
    if h[param] == w[param]
      return pluralize_verbs(h[param])
    else
      his = h[param].blank? ? '' : husband.short + '--' + h[param]
      hers = w[param].blank? ? '' : wife.short + '--' + w[param]
      return smart_join([his, hers], "; ")
    end
  end
    

  def current_locations_merged_hash
    merged = {}
    h = husband.current_location_hash
    w = wife.current_location_hash
    merged[:residence] = merge_one_location_param(h, w, :residence)
    merged[:work] = merge_one_location_param(h, w, :work)
    merged[:travel] = merge_one_location_param(h, w, :travel)
    merged[:temp] = merge_one_location_param(h, w, :temp)
    merged[:reported_location] = merge_one_location_param(h, w, :reported_location)
    return merged
  end

end
