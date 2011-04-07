# == Schema Information
# Schema version: 20110402104657
#
# Table name: members
#
#  id                            :integer(4)      not null, primary key
#  last_name                     :string(255)
#  short_name                    :string(255)
#  sex                           :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  middle_name                   :string(255)
#  family_id                     :integer(4)
#  birth_date                    :date
#  spouse_id                     :integer(4)
#  country_id                    :integer(4)
#  first_name                    :string(255)
#  status_id                     :integer(4)
#  ministry_comment              :string(255)
#  ministry_id                   :integer(4)
#  residence_location_id         :integer(4)
#  name                          :string(255)
#  name_override                 :boolean(1)
#  child                         :boolean(1)
#  work_location_id              :integer(4)
#  temporary_location            :string(255)
#  temporary_location_from_date  :date
#  temporary_location_until_date :date
#

class Member < ActiveRecord::Base
  include NameHelper
  include ApplicationHelper
  
  attr_accessor :previous_spouse  # to help with cross-linking when changing/deleting spouse
  
  has_many :contacts, :dependent => :destroy 
  has_many :travels, :dependent => :destroy 
  has_many :field_terms,  :dependent => :destroy 
  has_one  :health_data, :dependent => :destroy
  has_one  :personnel_data, :dependent => :destroy
  belongs_to :spouse, :class_name => "Member", :foreign_key => "spouse_id"
  belongs_to :family
  belongs_to :country
  belongs_to :bloodtype 
  belongs_to :education
  belongs_to :ministry
  belongs_to :residence_location, :class_name => "Location"#, :foreign_key => "residence_location_id"
  belongs_to :work_location, :class_name => "Location"#, :foreign_key => "work_location_id"
  belongs_to :employment_status
  belongs_to :status
  validates_presence_of :last_name, :first_name, :name
  validates_uniqueness_of :spouse_id, :allow_blank=>true
  validate :family_record_exists
  validate :valid_spouse
  validates_uniqueness_of :name, :id

  after_initialize :inherit_from_family
  before_validation :set_indexed_name_if_empty
  before_create :build_personnel_data
  before_create :build_health_data
  before_save   :unlink_spouses_if_indicated
#  after_create :create_personnel_data
#  after_create :create_health_data
  after_save  :cross_link_spouses
  before_destroy :check_if_family_head
  before_destroy :check_if_spouse
  
  def family_head
    return Family.find_by_id(family_id) && (family.head_id == self.id)
  end 

  def is_single?
    return spouse.nil?
  end
  
  # Make array of children. This version uses age rather than child attribute as criterion
  def children
    age_cutoff = 19
    birthdate_cutoff = Date::today() - age_cutoff.years
    family.members.where("birth_date > ?", birthdate_cutoff)
  end

  # Copy last name & other family-level attributes to new member as defaults
  def inherit_from_family
    return unless new_record? &&             # Inheritance only applies to new, unsaved records
                  family_id && Family.find_by_id(family_id) # must belong to existing family
    self.last_name = family.last_name
    self.status = family.status
    self.residence_location = family.residence_location
  end

  # Valid record must be linked to an existing family
  def family_record_exists
    # It should be enough to say ... unless family, but that does not seem to catch
    #   newly-created records with an invalid ID. If we say ...Family.find(family_id),
    #   it fails when id = nil, so we resort to Family.find_by_id(family_id)
    errors.add(:family, "must belong to an existing family") unless 
        family_id && Family.find_by_id(family_id)
  end

  # Validate spouse based on opposite sex, age, single ...
  def valid_spouse
    return if self.spouse.nil? 
    errors.add(:spouse, "spouse can't be same sex") if
      self.sex == spouse.sex
    errors.add(:spouse, "spouse not old enough to be married") if
      (spouse.age_years || 99)< 16
    errors.add(:spouse, "proposed spouse is already married") if
      spouse.spouse_id && (spouse.spouse_id != self.id)
    errors.add(:spouse, "must un-marry existing spouse first") if
      @previous_spouse && (@previous_spouse.spouse_id == self.id) && (spouse != @previous_spouse)
  end

  def country_name
    Country.find(country_id).name if country_id
  end

  def country_name= (name)
    country = Country.find_by_name(name)
    self.country_id = country.id if country
  end

   def family_name
     if !family_id.nil?
       Family.find(family_id).head.name
     end  
   end

   def family_name= (name)
     my_head = Member.find_by_name(name)
     self.family_id = my_head.family_id if my_head
   end

   def male_female
     return :female if self.sex.upcase == 'F'
     return :male if self.sex.upcase == 'M'
   end
   
   def male?
     return self.male_female == :male
   end
     
   def female?
     return self.male_female == :female
   end
     
   def other_sex
     case self.sex
       when 'M', 'm' then 'F'
       when 'F', 'f' then 'M'
       else              nil
     end  
   end  

   def spouse_name
     return nil unless self.spouse
     self.spouse.name
   end

#   # Set spouse by looking up name 
#   def spouse_name= (name)
#     myspouse = Member.find_by_name(name)
#     self.spouse_id = myspouse.id if myspouse
#   end

  def marry(new_spouse)
    return nil if new_spouse.nil?
    return nil if new_spouse.sex == self.sex
    return nil if self.spouse || new_spouse.spouse  # can't marry if either is already married
    return nil if (self.age_years || 99) < 16 || (new_spouse.age_years || 99) < 16
    # Now, with all that out of the way
    self.spouse = new_spouse
    cross_link_spouses
    return self.sex == "M" ? self : new_spouse   # for what it's worth, return the husband's object
  end


  # Possible Spouses: Return from members table a list of all the
  # ones that could be spouses of this one: e.g. same last name,
  # opposite sex, age over 18, whatever. This is for the selection
  # box.
  def possible_spouses
    return [] if self.last_name.blank? || self.sex.blank?
    my_sex = self.sex.upcase
    spouse_sex = my_sex == 'M' ? 'F' : 'M'
#puts "**** Possible Spouses called for member #{self.last_name}, #{self.spouse_id}, #{spouse_sex}"
    age_18_date = Date.today - 18.years
    my_last_name = self.last_name
# Member.all.each {|m| puts "** Member #{m.id}, name=#{m.name}, child=#{m.child} " }
    possibilities = Member.where(:last_name => my_last_name, 
                  :sex => spouse_sex, :child=>false).
    #              where("birth_date <= ? OR birth_date IS NULL", age_18_date).
                  order("name")
    # delete from possibilities everyone
    # who is married to someone else.
    # (even works if our own id is still nil, undefined)
# puts "***** Original Possibilities = #{possibilities.each {|x| x.to_label + '::'}}"
    possibilities.delete_if {|x| x.spouse_id && x.spouse_id != self.id}
# puts "***** Possibilities = #{possibilities.each {|x| x.to_label + '::'}}"
    return possibilities 
  end
  
  def active
    return Status.find(self.status_id).active == true 
  end

  def on_field
    return self.status_id && Status.find(self.status_id).on_field 
  end

  def age_years
     return nil if self.birth_date.nil? 
     return (Date.today-self.birth_date)/365.25
  end

  # Return string with person's age in _human_ time (as appropriate for age). See time_human.   
  def age
     return nil if self.birth_date.nil? 
     return time_human((Date.today - self.birth_date) * SECONDS_PER_DAY)
  end
  
  # Return string with person's current location (& work location) based on member.residence_location,
  # member.work_location, member.temporary_location, and travel records
  # Options
  #   :missing = what to supply if residence or work location is missing or is 'unspecified'
  def current_location(options={})
    residence = description_or_blank(residence_location, options[:missing] || '?')
    work = description_or_blank(work_location, options[:missing] || nil)
    answer = residence
    # Now we have the location but subject to travel and temporary moves.
    answer += " (#{work})" if !work.blank? && (work != residence)
  #  answer += ". "
    answer += " (#{travel_location})" if travel_location
    answer += " (#{temp_location})" if temp_location
    return answer
  end

  # Returns true for people with off-field status (alumni, retired...) who are on a current trip to the field.
  def visiting_field?
    return false if status && status.on_field  # This only applies to visitors, not those those w "on_field" status
    current_travel = travels.where("date < ? and arrival is true and (return_date is ? or return_date > ?)", 
         Date.today, nil, Date.today).order("date desc").limit(1)[0]
    return ! current_travel.nil?
  end  

  def travel_location
#puts "travel_location, member=#{self.attributes}, status=#{status_id}, on_field=#{status.on_field if status}"

    # We look at the most recent travel, if any, with dates including today. When no return date is specified,
    # a trip beginning in past is considered to be still in progress. This means it's important to terminate
    # trips whether by using a return date or adding a more recent flight (return or otherwise)
    if spouse
      current_travel = Travel.where("member_id = ? or (member_id = ? and with_spouse)", self.id, spouse_id).
           where("date < ? and (return_date is ? or return_date > ?)", 
           Date.today, nil, Date.today).order("date desc").limit(1)[0]
    else
      current_travel = travels.where("date < ? and (return_date is ? or return_date > ?)", 
           Date.today, nil, Date.today).order("date desc").limit(1)[0]
    end      
    if current_travel
      if visiting_field?  # Someone visiting the field
        answer = "travel: arrived on field #{current_travel.date.to_s(:short)}"
        if current_travel.return_date
          answer << ", leaves #{current_travel.return_date.to_s(:short)}"
        end
        return answer
      elsif status && status.on_field && !current_travel.arrival  # if on-field person has traveled (according to travel schedule)
        answer = "travel: left field #{current_travel.date.to_s(:short)}"
        if current_travel.return_date
          answer << ", returns #{current_travel.return_date.to_s(:short)}"
        end
        return answer
      end  
    end     
    return nil
  end
  
  def temp_location
    if !temporary_location.blank? && temporary_location_from_date <= Date.today &&
                                     temporary_location_until_date >= Date.today
      return "temporary location: #{temporary_location}, #{temporary_location_from_date.to_s(:short)} to " +
             " #{temporary_location_until_date.to_s(:short)}"
    else
      return nil
    end         
  end

private

  # Return true if I have existing spouse whose spouse_id points back to me (as it ordinarily should)
  def my_spouse_links_to_me
    return spouse && spouse.spouse_id == self.id
  end  

  # If self is deceased, changed spouse, etc. then need to unlink spouse
  # Call-back on before_save, so changed attributes will be saved
  def unlink_spouses_if_indicated
    # Unlink spouses if member is deceased
    if spouse_id && status_id && status.code=='deceased'
      spouse.update_attribute(:spouse_id, nil) if my_spouse_links_to_me
      self.spouse_id = nil  # This method unlink_spouse is a before_save callback, so new nil value will be saved
      return
    end       
    # If we've just removed spouse, we need to unlink the spouse, too
    if spouse_id.nil? && @previous_spouse
      @previous_spouse.update_attribute(:spouse, nil)
      return 
    end
  end
 
  # Update spouse's record if a spouse is defined. 
  def cross_link_spouses
#    puts "**** Crosslinking: spouse_id=#{spouse_id}, @prev_spouse=#{@previous_spouse}, status=#{status.code if status}: "
    # Make sure the spouse links back to self...
    if spouse_id # 
      if !spouse  # i.e. if spouse not found in db, db is corrupted
        spouse_id = nil
        return nil
      end 
      if spouse.spouse_id != self.id # spouse is not linked back to member
        #puts "**** Crosslinking: self.sex=#{self.sex}, spouse_id=#{spouse_id || ''}, spouse.sex=#{spouse.sex}, spouse.age=#{spouse.age_years}"
        # Register error if same sex
        if spouse.sex == self.sex
          self.update_attribute(:spouse_id, nil)
          self.errors.add[:spouse, "Spouse can't be same sex"]    
          return nil
        end  
        spouse.spouse_id = self.id  # my spouse is married to me
        if self.male?
          husband = self
          wife = spouse
        else
          wife = self
          husband = spouse
        end
        wife.family_id = husband.family_id
        begin
          spouse.save!
          self.save!
          rescue 
     #     flash.now[:notice] = "Unable to find or update spouse (record id #{spouse_id})"
           logger.error "***Unable to find or update spouse (record id #{spouse_id})"
           puts "***Unable to find or update spouse (record id #{spouse_id}), error #{spouse.errors}"
           nil
        end # rescue block    
        return husband
      end # if spouse.spouse_id != self.id
    end # if spouse_id  
  end # cross_link_spouses

  
  def check_if_family_head
    if family_head
      self.errors.add(:delete, "Can't delete head of family.")
      return false
    else
      true  
    end
  end
  
  def check_if_spouse
    # if someone is married to me, don't delete me from the database
    orphan_spouse = Member.find_by_spouse_id(self.id)
    if orphan_spouse
      self.errors.add(:delete, "can't delete while still spouse of #{orphan_spouse.to_label}")
      return false
    else
      return true
    end  
  end
  
  # return a string in days, weeks, months, or years, whatever makes sense for the age, from
  # time (t) in seconds. Sensible rounding is applied as we would normally describe someone's age.
  # Thus time_human(187000) = "2 days," time_human(34000000) = "12 months", time_human(120000000) = "3.8 years"
  # d, w, m, and y are day, week, month and year in seconds. Not efficient to calculate it each call, but 
  # helps make clear what we're doing, and we can't define constants in a function
  def time_human(t, expand=true)    # where t is time in seconds
    return nil if t.nil?
   
    d = SECONDS_PER_DAY  
    w = SECONDS_PER_WEEK
    m = SECONDS_PER_MONTH
    y = SECONDS_PER_YEAR
    return "#{(t/d).floor} days" if t < m
    return sprintf("%0.1f weeks", t/w) if t < (m * 2)
    if t < (m * 24)
      s = sprintf("%d months", t/m, t/y) 
      s = sprintf("%d months (%0.1f years)", t/m, t/y) if expand
      return s
    end
    return sprintf("%1.1f years", t/y) if t < (y * 7)
    return "#{(t/y).to_i} years"
  end
end
