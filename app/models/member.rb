# == Schema Information
# Schema version: 20120427123138
#
# Table name: members
#
#  id                            :integer         not null, primary key
#  last_name                     :string(255)
#  short_name                    :string(255)
#  sex                           :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  middle_name                   :string(255)
#  family_id                     :integer
#  birth_date                    :date
#  spouse_id                     :integer
#  country_id                    :integer
#  first_name                    :string(255)
#  status_id                     :integer
#  ministry_comment              :string(255)
#  ministry_id                   :integer
#  residence_location_id         :integer
#  name                          :string(255)
#  name_override                 :boolean
#  child                         :boolean
#  work_location_id              :integer
#  temporary_location            :string(255)
#  temporary_location_from_date  :date
#  temporary_location_until_date :date
#  school                        :text
#  school_grade                  :integer
#


class Member < ActiveRecord::Base
  include NameHelper
  include ApplicationHelper
  include FilterByStatusHelper
  
  # ToDo: This can probably be refactored to use the built-in changed_attributes of the model
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
  belongs_to :status
  validates_presence_of :last_name, :first_name, :name, :family
  validates_uniqueness_of :spouse_id, :allow_blank=>true
  validate :valid_spouse
  validates_uniqueness_of :name
  validate  :valid_birth_date #,  :less_than => Date.today+1.day

  after_initialize :inherit_from_family
  before_validation :set_indexed_name_if_empty
  before_create :build_personnel_data
  before_create :build_health_data
  before_save   :unlink_spouses_if_indicated
  after_save  :cross_link_spouses
  before_destroy :check_if_family_head
  before_destroy :check_if_spouse
 
  def those_umbrella
    # This one is here because the definition is different between member and family classes
    umbrella_status = EmploymentStatus.find_by_code('umbrella').id
    self.joins(:personnel_data).where("employment_status_id = ?", umbrella_status)
  end 
  
  # Takes name in some free text formats and returns array of matches
  # To find Donald (Don) Duck, all of these will match:
  # D Duck; Duck, D; Duck, Don; D Du; Do Du; Du; Don; Donald; Dona Du;
  # Conditions parameter will pre-filter the output, e.g. can be ["status IN ?", [1,3,5]], "sex='M'", etc.
  def self.find_with_name(name, conditions="true")
#puts "Find_with_name #{name}"
    return [] if name.blank?
    filtered = self.where(conditions)
    result = filtered.where("first_name LIKE ?", name+"%") + filtered.where("last_name LIKE ?", name+"%") + 
      filtered.where("name LIKE ?", name+"%") + filtered.where("short_name LIKE ?", name+"%")
    if name =~ /(.*),\s*(.*)/
      last_name, first_name = $1, $2
    elsif name =~ /(.*)\s(.*)/
      last_name, first_name = $2, $1
    else
      last_name = first_name = nil
    end
    if last_name && first_name      
      result += filtered.where("last_name LIKE ? AND ((first_name LIKE ?) OR (short_name LIKE ?))", 
          last_name+"%", first_name+"%", first_name+"%")
    end
    return result.uniq.compact
  end

  # Find members who are marked as being on the field (status.on_field == true) but who
  # have a current travel record showing their departure with "term_passage". This is a 
  # logical mismatch as they should not be "on field" if they have left at end of term.
  def self.on_field_mismatches
    field_statuses = Status.field_statuses
    departures = Travel.current.joins(:member).where(
          "status_id IN (?) and term_passage and NOT arrival", field_statuses)
    mismatches = departures.map {|t| {:member=>t.member, :travel=>t}}
    add_spouses(mismatches)
  end    

  # Find members who are NOT marked as being on the field (status.on_field == false) but who
  # have a recent travel record showing their arrival with "term_passage". This is a 
  # logical mismatch as they should be "on field" if they have arrived at beginning of term.
  def self.off_field_mismatches
    field_statuses = Status.field_statuses
    off_field_members = Member.joins(:travels).
      where("members.status_id NOT IN (?) AND term_passage AND arrival AND "+
            "travels.date < ? AND travels.date > ?", 
            field_statuses, Date.today, Date.today-3.months).all.uniq
            # "+deceased_status" as part of NOT IN limits members to the living!
    # Select those members whose MOST RECENT travel is an "term passage" arrival
    mismatches = off_field_members.map do |member| 
      most_recent = member.most_recent_travel
      if most_recent.arrival && most_recent.term_passage && member.living
        {:member=>member, :travel=>most_recent}
      end # "else return nil" is implied
    end.compact # remove nils leaving only one hash for each member/latest_travel pair.
    add_spouses(mismatches)
  end
  
  def self.add_spouses(mismatches)
    with_spouses = []
    mismatches.each do |mismatch|
      with_spouses << mismatch
      if mismatch[:travel].with_spouse
        with_spouses << {:member=>mismatch[:member].spouse, :travel=>mismatch[:travel]}
      end
    end
    return with_spouses
  end
    
  def self.mismatched_status
    return off_field_mismatches + on_field_mismatches
  end

  def living
    status && status.code.to_s != 'deceased'
  end
  alias_method :alive, :living 

  def family_head
    return Family.find_by_id(family_id) && (family.head_id == self.id)
  end 

  def is_single?
    return spouse.nil?
  end

  def is_married?
    return !spouse.nil?
  end

  def employment_status
    return personnel_data ? personnel_data.employment_status : nil
  end  
  
  def employment_status_code
    return nil unless personnel_data && personnel_data.employment_status
    return personnel_data.employment_status.code 
  end  
  
  def org_member
    return nil unless personnel_data && personnel_data.employment_status
    return personnel_data.employment_status.org_member
  end
      
  def age_range
    case age_years
      when nil then '?'
      when 0..30 then  ' 0-30'
      when 30..45 then '30-45'
      when 45..60 then '45-60'
    when 60..999 then  '> 60'
    end
  end

  def years_of_service
    start_date = personnel_data.date_active
    end_date = personnel_data.end_nigeria_service? ? personnel_data.end_nigeria_service? : Date.today
    if start_date && end_date
      return (end_date-start_date)/365.25
    else
      return nil
    end
  end

  def years_of_service_range
    case years_of_service
      when nil then    '?'
      when 0..5 then   '  0-5'
      when 5..10 then  ' 5-10'
      when 10..15 then '10-15'
      when 15..20 then '15-20'
    when 20..999 then  '> 20'
    end
  end

  def <=>(other)
    self.name <=> other.name
  end

  # The most recent, including present term.
  def most_recent_term
    terms = self.field_terms.sort
    terms.delete_if {|t| t.future? }
    return terms.last
  end
  
  # The earliest future term
  def pending_term
    terms = self.field_terms.sort
    first_future = terms.find_index {|t| t.future?} 
    return first_future ? terms[first_future] : nil
  end
  
  def current_term
    terms = self.field_terms.sort
    first_current = terms.find_index {|t| t.current?} 
    return first_current ? terms[first_current] : nil
  end    
  
  # Use organization guidelines to estimate length of HA based on how long current term is/was
  def estimate_home_assignment_duration(term_start, term_finish)
    term_duration = most_recent_term.best_end_date - most_recent_term.best_start_date 
    est_ha_duration = (term_duration-365)/3
    return est_ha_duration
  end
  
  # Determine or estimate the dates of next home assignment for those on the field
  def next_home_assignment
  #  return [nil, nil] unless current_term
    start = ending = eot_status = end_estimated = nil
    if pending_term
      if pending_term.best_start_date
        ending = pending_term.best_start_date - 1
      end
    end        
    if most_recent_term
      best_end_date = most_recent_term.best_end_date
      best_start_date = most_recent_term.best_start_date
      if best_end_date
        start = best_end_date + 1
        if self.personnel_data.est_end_of_service  # Is there an estimated end-of-service/retirement date?
          if start > self.personnel_data.est_end_of_service - 360  # consider retiring if within a year of date
            eot_status = 'final'
            ending ||= eot_status  # For ease of formatting, but might want to leave as nil
          end
        end
        # If end of HA not specified, estimate it using org. formula for HA duration
        if ending.nil? && most_recent_term.best_start_date
          ending = start + estimate_home_assignment_duration(best_start_date, best_end_date)
          end_estimated = '(est)'
        end
      end
    end
    return {:start=>start, :end=>ending, :eot_status=>eot_status, :end_estimated=>end_estimated}
  end
  
  def city
    return residence_location.city.name
  end
  
  # Make array of children. This version uses age rather than child attribute as criterion
  def children(include_grown=false)
    family.children(include_grown)  
  end

  # Dependent is true for family head, spouse, and children. False for others
  # (which would be grown children with child=false)
  def dependent
      return (self.status.nil? || self.status.code != 'deceased') && 
           ( 
              (self == family.head) || self.spouse || 
              description_or_blank(self.personnel_data.employment_status, '?', :code) == 'mk_dependent'
           )
  end  

  # Copy last name & other family-level attributes to new member as defaults
  def inherit_from_family
#puts "inherit_ff, new=#{new_record?}, family=#{family}"
    return unless new_record? && !family.nil?            # Inheritance only applies to new, unsaved records

#    return unless new_record? &&             # Inheritance only applies to new, unsaved records
#                  family_id && Family.find_by_id(family_id) # must belong to existing family
    self.last_name ||= family.last_name
    self.status ||= family.status
    self.residence_location ||= family.residence_location
  end

  # Valid record must be linked to an existing family
  def family_record_exists
    # It should be enough to say ... unless family, but that does not seem to catch
    #   newly-created records with an invalid ID. If we say ...Family.find(family_id),
    #   it fails when id = nil, so we resort to Family.find_by_id(family_id)
    errors.add(:family, "must belong to an existing family") unless 
        family_id # && Family.exists?(family_id)
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

  def valid_birth_date
    return if birth_date.blank?
    if birth_date.to_date > Date.today + 1.day
      errors.add(:birth_date, "can't be in future!") 
    end
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
    return self.status_id && self.status.on_field 
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
  

  def current_location_hash(options={})
    answer = {
        :residence => description_or_blank(residence_location, options[:missing] || '?'),
        :work => description_or_blank(work_location, options[:missing] || nil),
        :travel => travel_location,
        :temp => temp_location
        }
    return answer
  end     

  # Return string with person's current location (& work location) based on member.residence_location,
  # member.work_location, member.temporary_location, and travel records
  # Options
  #   :missing = what to supply if residence or work location is missing or is 'unspecified'
  def current_location(options={})
    cur_loc_hash = current_location_hash(options)
    answer = cur_loc_hash[:residence]
    answer += " (#{cur_loc_hash[:work]})" if !cur_loc_hash[:work].blank? && (cur_loc_hash[:work] != cur_loc_hash[:residence])
    answer += " (#{cur_loc_hash[:travel]})" if cur_loc_hash[:travel]
    answer += " (#{cur_loc_hash[:temp]})" if cur_loc_hash[:temp]
    return answer
  end

  # Returns true for people with off-field status (alumni, retired...) who are on a current trip to the field.
  def visiting_field?
    return false if status && status.on_field  # This only applies to visitors, not those those w "on_field" status
    return in_country_per_travel
#    if spouse
#      current_travel = Travel.where("member_id = ? or (member_id = ? and with_spouse)", self.id, spouse_id).
#         where("date < ? and arrival is true and (return_date is ? or return_date > ?)", Date.today, nil, Date.today).
#         order("date desc").limit(1)[0]    
#    else
#      current_travel = travels.where("date < ? and arrival is true and (return_date is ? or return_date > ?)", 
#         Date.today, nil, Date.today).order("date desc").limit(1)[0]
#    end
#    return ! current_travel.nil?
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
        answer = "arrived on field #{current_travel.date.to_s(:short).strip}"
        if current_travel.return_date
          answer << ", leaves #{current_travel.return_date.to_s(:short).strip}"
        end
        return answer
      elsif status && status.on_field && !current_travel.arrival  # if on-field person has traveled (according to travel schedule)
        answer = "left field #{current_travel.date.to_s(:short).strip}"
        if current_travel.return_date
          answer << ", returns #{current_travel.return_date.to_s(:short).strip}"
        end
        return answer
      end  
    end     
    return nil
  end
  
  def today_in_date_range(start_date, end_date)
    inrange = Range.new(start_date || Date.yesterday, end_date || Date.tomorrow, 1).include? Date.today 
#puts "** #{start_date} to #{end_date}: #{inrange}"
    return inrange
  end

  def temp_location
    if !temporary_location.blank? && 
        today_in_date_range(temporary_location_from_date, temporary_location_until_date)
      from_formatted  = temporary_location_from_date ?  temporary_location_from_date.to_s(:short) : 'unknown'  
      until_formatted = temporary_location_until_date ? temporary_location_until_date.to_s(:short) : 'unknown'  
      return "temporary location: #{temporary_location}, #{from_formatted} to #{until_formatted}"
    else
      return nil
    end         
  end
  
  # Finds primary contact for this member:
  # * His own contact record marked as primary (arbitrary selection if more than one)
  # * His spouse's contact marked as primary, if he has none himself
  # * His family head's primary_contact in the case of a child.
  def primary_contact(options={})
    primary = self.contacts.where(:is_primary=>true).first
    primary ||= (self.family.head.primary_contact if self.child && family.head.primary_contact)
    if !primary && is_married? && options[:no_substitution].nil?
      primary = spouse.contacts.where(:is_primary=>true).first
    end
    return primary
  end

  # Email address in member's primary contact record. Return one only with email_1 having priority.
  def email
    self.primary_contact ? (primary_contact.email_1 || primary_contact.email_2) : nil
  end

  def current_travel
    if spouse
      spouse_travel = Travel.current.where("member_id = ? and with_spouse = ?", spouse_id, true)
    else
      spouse_travel = []
    end
    return Travel.current.where("member_id = ?", self.id) + spouse_travel
  end
  
  # This is the most recent trip regardless of the return status.
  def most_recent_travel
    if spouse
      spouse_travel = Travel.not_future.where("member_id = ? and with_spouse = ?", spouse_id, true)
    else
      spouse_travel = []
    end
    return (Travel.not_future.where("member_id = ?", self.id) + spouse_travel).sort.last
  end
    

  def pending_travel
    if spouse
      spouse_travel = Travel.pending.where("member_id = ? and with_spouse = ?", spouse_id, true)
    else
      spouse_travel = []
    end
    return Travel.pending.where("member_id = ?", self.id) + spouse_travel
  end  

#  def in_country_per_travel
#    most_recent_travel = self.travels.where('date < ?', Date.today).order('date asc').last
#    if most_recent_travel.nil?
#      return self.on_field
#    else
#      return most_recent_travel.arrival
#    end
#  end
  def in_country_per_travel
    rt = self.most_recent_travel
    if rt
      if rt.date == Date.today
        # "in country" should always be true on date of travel, whether coming or going.
        return true
      else
        # date must be prior to today, so person is in country if the travel was an arrival
        return rt.arrival
      end
    end
    # There is NO travel record for this person, so use whatever status is posted already  
    return self.on_field
  end
  
  def self.those_in_country
    return self.all.delete_if {|m| !m.in_country_per_travel}
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
  
end
