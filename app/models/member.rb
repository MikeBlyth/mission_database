class Member < ActiveRecord::Base
  has_many :contacts, :dependent => :destroy 
  has_many :travels, :dependent => :destroy 
  has_many :field_terms,  :dependent => :destroy 
  belongs_to :spouse, :class_name => "Member", :foreign_key => "spouse_id"
  belongs_to :family
#  has_one    :family 
  belongs_to :country
  belongs_to :bloodtype 
  belongs_to :education
  belongs_to :ministry
  belongs_to :location
  belongs_to :employment_status
  belongs_to :status
  validates_presence_of :last_name, :first_name, :name
  validates_uniqueness_of :spouse_id, :allow_blank=>true
  validates_uniqueness_of :name, :id

  before_validation :set_indexed_name_if_empty
  before_save :set_family_head_if_no_family
  after_create :link_member_and_family
#  after_save  :update_family_record_if_family_head
  after_save  :cross_link_spouses
  before_destroy :check_if_family_head
  before_destroy :check_if_spouse
  
  SECONDS_PER_YEAR = 3600*24*365.25
  SECONDS_PER_DAY = 3600*24
  SECONDS_PER_WEEK = SECONDS_PER_DAY * 7
  SECONDS_PER_MONTH = SECONDS_PER_YEAR / 12

  #== Relate the Family to the newly-created or updated member
  # This is a bit tricky because member and family are related in two ways.
  # * A member BELONGS to a family through family_id (everyone belongs to a family)
  # * A family BELONGS to a member through :head_id  (a family belongs to the head of the family)
  # When creating a new member, the user should be able to assign him/her to an existing family.
  # If that is not done, then the new member should constitute his own family 
  # So the logic of what we're doing in before_ and after_save is:
  # 1) If the member does not have an existing one
  #    - save the new family record with a DUMMY head_id since we don't know the member's id yet
  #    - relate the member to the new family through self.family_id = my_own_family.id
  #    - make the member head of his/her own family
=begin
  def link_member_and_family
#  puts "******** #{name}, family id = #{family_id}, family_name = #{family.to_label if family}"
    if family_id.nil? ||  family.nil?
      my_own_family = Family.create(:status_id => self.status_id, :location_id => self.location_id)
        # note that until the member record is saved and update_family_record_if_family_head is called,
        # this family will not point to anyone as the head.
      self.family_id = my_own_family.id
      self.family_head = true
    end
  end    
=end

  # if I don't already belong to a valid family, then I must be head of my own family
  #   -- in a new record, we can't yet set family_id because it does not yet have an id
  #   -- in an existing record with no family_id, set the family_id to self
  # This is on "before save" callback so executes before any create or update of a member
  def set_family_head_if_no_family
    self.family_id = self.id if family_head   # family <== nil if new, self if existing 
    if self.family_id.nil? ||  family.nil?    # If no valid family is set
      self.family_head = true                 #    Make self the head of family
      self.family_id = self.id                #    ... will be valid id if existing, else nil
    end
  end
  
  def family_id
#  puts "******family_head=#{attributes['family_id']}, family_id=#{attributes['family_id']}, id=#{self.id}, family_id=#{attributes['family_id']}"
    if family_head || (attributes['family_id'] == 0)
      return self.id
    else
# debugger
      return self.attributes['family_id']
    end  
  end    
  
  # I am new record and I don't already belong to a family? Then make one for me!
  # This is on 'after_create' callback, so executes only for new records
  def link_member_and_family
    if family_id.nil? ||  family.nil?
      my_own_family = Family.new(:head_id => self.id, :status_id => self.status_id, :location_id => self.location_id)
      my_own_family.id = self.id
      my_own_family.save!
      self.update_attributes(:family_id => self.id)
    end
  end
  
  def set_indexed_name_if_empty
    if self.name.blank?
      self.name = indexed_name
    end
  end    
  
  

  # AFTER saving the member, we just need to be sure that the family record
  #   points to this member if the member is marked as head of family.
  #   (All members without a family are marked as head-of-family in before_save, above.)
  def update_family_record_if_family_head
    if family_head && family.head != self.id
 #     self.family.update_attributes(:head_id => self.id)
    end
 #     f = self.family
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
#puts "******Family_name= function. Name=#{name}, family_head=#{family_head.to_label if family_head}"
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
     
   def spouse_name
     self.spouse.name
   end

   def spouse_name= (name)
     myspouse = Member.find_by_name(name)
     self.spouse_id = myspouse.id if myspouse
   end

  def cross_link_spouses
  # Update spouse's record if a spouse is defined. Not sure it's a good idea to do this 
  # automatically ...
  # If we do it w/o any error checking, must be sure user can only assign a valid member as a spouse
  # (What if someone else deletes the spouse --- don't ever delete anyone :-)
    if !spouse_id.nil? && spouse.spouse_id != self.id
      begin
        spouse.spouse_id = self.id  # my spouse is married to me
        if self.male?
          husband = self
          wife = spouse
        else
          wife = self
          husband = spouse
        end
        wife.family_id = husband.family_id
        wife.family_head = false
        husband.family_head = true

        spouse.save!
        self.save!
        rescue 
     #     flash.now[:notice] = "Unable to find or update spouse (record id #{spouse_id})"
  logger.error "***Unable to find or update spouse (record id #{spouse_id})"
      end    
    end
  end

  def check_if_family_head
    if family_head
puts "******** Can't delete head of family.*******"
      self.errors.add(:delete, "Can't delete head of family.")
      # ! uncomment this next line to prevent unwanted delete
      # ! leaving it commented while doing a lot of deletes for testing
      raise ActiveRecord::RecordInvalid
      return false
    else
      true  
    end
  end
  
  def check_if_spouse
    # if there IS a valid spouse, remove the spouse's link to this member
    orphan_spouse = Member.find_by_spouse_id(self.id)
    if orphan_spouse
puts "******Deleting would orphan spouse #{orphan_spouse.to_label}"
      errors[:delete] << "can't delete while still spouse of #{orphan_spouse.to_label}"
      raise ActiveRecord::RecordInvalid
    else
      return true
    end  
  end
  
# EXAMPLES OF NAME FORMS 
# to_label:         Blyth, Michael
# indexed_name:     Blyth, Michael J. (Mike)
# full_name:        Michael John Blyth
# full_name_short:  Mike Blyth
# full_name_with_short: Michael John Blyth (Mike)
# last_name_first:  Blyth, Michael John    (default)
#  :initial=>true   Blyth, Michael J.
#  :short=>true     Blyth, Mike J.
#  :short_paren=>true Blyth, Michael John (Mike)
#  :middle=>false   Blyth, Michael  

  def to_label
    last_name_first
  end
  
  def to_s
    last_name_first + " (#{self.id})"
  end

  # Indexed_name is the full name stored in the table. It is formed automatically on record
  # creation, re-formed if blank on updates. It must be unique. Stored in :name field of members table 
  def indexed_name
    last_name_first(:initial=>true, :paren_short => true)
  end
  
  def full_name
    s = self.first_name
    s = s + ' ' + self.middle_name unless self.middle_name.blank?
    s = s + ' ' + self.last_name
    return s
  end

  def full_name_short
    if short_name.blank?
      s = first_name + " " + last_name
    else
      s = short_name + " " + last_name
    end
  end

  def full_name_with_short_name
    s = self.full_name
    s = s + ' (' + self.short_name + ')' unless (self.short_name.blank? ) || self.short_name.eql?(self.first_name)
    return s
  end
  
  # Full name with last name first: Johnson, Alan Mark
  # Options
  # * :short => _boolean_ default false; use the short form of first name (e.g. "Al")
  # * :paren_short => boolean default false; append short name, if any, in "( )" 
  # * :initial => _boolean_ default false; use the initial instead of whole _middle_ name
  # * :middle => _boolean_ default true; include the middle name (or initial)
  def last_name_first(options={})
    options[:short] = false if options[:paren_short] # paren_short overrides the short option
    if options[:short] && !short_name.blank?   # use the short form of first name if it's defined
      first = short_name
    else
      first = first_name
    end
    if options[:initial] && !middle_name.blank?   # use middle initial rather than whole middle name?
      middle = middle_name[0] << '.'
    else
      middle = middle_name || ''
    end
    if (options[:paren_short]) && !short_name.blank? && short_name =! first
      first = first + " x(#{short_name})"
    end
    s = last_name + ', ' + first 
    s << (' ' + middle) unless options[:middle] == false || middle.empty?
    return s    
  end
  
  # def spouse_name
  #   if self.spouse.nil?
  #     return ''
  #   else
  #     return Member.find(self.spouse).firstname
  #   end
  # end
  # 
  
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
    possibilities = Member.where(:last_name => my_last_name, 
                  :sex => spouse_sex).
    #              where("birth_date <= ? OR birth_date IS NULL", age_18_date).
                  order("name")
    # delete from possibilities everyone
    # who is married to someone else.
    # (even works if our own id is still nil, undefined)
    possibilities.delete_if {|x| x.spouse_id && x.spouse_id != self.id}
# puts "***** Possibilities = #{possibilities.each {|x| x.to_label + '::'}}"
    return possibilities 
  end
  
  def active
    return Status.find(self.status_id).active == true 
  end

  def on_field
    return Status.find(self.status_id).on_field == true 
  end

  # Return string with person's age in _human_ time (as appropriate for age). See time_human.   
  def age
     return nil if self.birth_date.nil? 
     return time_human((Date.today - self.birth_date) * SECONDS_PER_DAY)
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
