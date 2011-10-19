# == Schema Information
# Schema version: 20110516135320
#
# Table name: travels
#
#  id               :integer         not null, primary key
#  date             :date
#  purpose          :string(255)
#  return_date      :date
#  flight           :string(255)
#  member_id        :integer
#  created_at       :datetime
#  updated_at       :datetime
#  origin           :string(255)
#  destination      :string(255)
#  guesthouse       :string(255)
#  baggage          :integer
#  total_passengers :integer
#  confirmed        :date
#  other_travelers  :string(255)
#  with_spouse      :boolean
#  with_children    :boolean
#  arrival          :boolean
#  time             :time
#  return_time      :time
#  driver_accom     :string(255)
#  comments         :string(255)
#  term_passage     :boolean
#  personal         :boolean
#  ministry_related :boolean
#  own_arrangements :boolean
#  reminder_sent    :date
#

# == Schema Information
# Schema version: 20110413013605
#
# Table name: travels
#
#  id               :integer         not null, primary key
#  date             :date
#  purpose          :string(255)
#  return_date      :date
#  flight           :string(255)
#  member_id        :integer
#  created_at       :datetime
#  updated_at       :datetime
#  origin           :string(255)
#  destination      :string(255)
#  guesthouse       :string(255)
#  baggage          :integer
#  total_passengers :integer
#  confirmed        :date
#  other_travelers  :string(255)
#  with_spouse      :boolean
#  with_children    :boolean
#  arrival          :boolean
#  time             :time
#  return_time      :time
#  driver_accom     :string(255)
#  comments         :string(255)
#  term_passage     :boolean
#  personal         :boolean
#  ministry_related :boolean
#  own_arrangements :boolean
#
require 'application_helper'

class Travel < ActiveRecord::Base
  extend ApplicationHelper
   
  belongs_to :member
  has_one :field_term, :foreign_key => :beginning_travel_id
  has_one :field_term, :foreign_key => :ending_travel_id
  validates_presence_of :date
  validate :name_info


  def <=>(other)
      self.date <=> other.date
  end
  
  def self.current_arrivals
    # self.includes(:member).where("arrival AND date <= ? AND ((return_date >= ? OR return_date IS NULL))", Date.today, Date.today)
    all_travel = self.includes(:member).where("date <= ?", Date.today).order('member_id,date DESC, other_travelers')  
    # Now all_travel is in order by member_id, then date. We can simply extract the records where 
    #   * first record for member (i.e. the last one) and
    #   * that record is an arrival OR that record's date is today (because the person is counted 
    #     as being currently arrived even if he is leaving today)
    cur_arr = []
    cur_member_id = nil
    cur_trav_names = nil
    all_travel.each do |t|
      if t.member_id  # this part is for travel records with a database member
        if t.member_id != cur_member_id  # next member in the list?
          cur_member_id = t.member_id
          cur_arr << t if (t.date == Date.today) || (t.arrival)
        end
      else # deal with travel records without a database members, only "other_travelers"
        if t.other_travelers != cur_trav_names  # next member in the list?
          cur_trav_names = t.other_travelers
          cur_arr << t if (t.date == Date.today) || (t.arrival)
        end
      end
    end
    return cur_arr
  end
  
  def self.current
    self.includes(:member).where("date <= ? AND (return_date >= ? )", Date.today, Date.today)
  end

  def self.current_or_no_return
    self.includes(:member).where("date <= ? AND (return_date >= ? OR return_date IS ? )", Date.today, Date.today, nil)
  end

  def self.past_or_no_return
    self.includes(:member).where("date <= ? AND (return_date < ? OR return_date IS ? )", Date.today, Date.today, nil)
  end

  def self.not_future
    self.includes(:member).where("date <= ?", Date.today)
  end    

  def self.pending
    return self.includes(:member).where("date > ? AND (date <= ? )", Date.today, 
        Date.today + Settings.travel.pending_window)
  end

  # This returns recently *updated* travel records
  def self.recently_updated(since=SiteSetting[:travel_update_window])
    return self.where('travels.updated_at > ?', Date.today - since.days).
      order('date ASC').includes(:member)
  end
  
  # For use in Where Is Everyone & any other directory information,
  # List who is visiting and give email & phone information as available.
  # Visitors are those with current incoming travel who are not "on field" as well
  # as any listed in the other_travelers field. Only those in the database can have a
  # contact information.
  def self.current_visitors
    travels = self.current_arrivals.where("(members.status_id NOT IN (?)) OR other_travelers > ''", Status.field_statuses)
    visitors = []
    travels.each do |t|
      # Add contact info if there is a (database) member as a visitor
      if t.member && t.member.primary_contact
        contact = t.member.primary_contact
        # Include the name only if there are other travelers to be distinguished
        contacts_name = t.other_travelers ? "#{t.member.full_name_short}: " : ''
        contacts = contacts_name + smart_join(
                                         [format_phone(contact.phone_1),
                                          t.member.primary_contact.email_1 ])
      else
        contacts = ''
      end
      visitors << {:names => t.travelers,
                   :arrival_date => t.date,
                   :departure_date => t.return_date,
                   :contacts => contacts
                   }
    end
    return visitors
  end 

  def to_label
    "#{date.to_s} #{flight}"
  end

  def to_s
    "#{self.travelers}--#{date.to_s.strip} #{arrival ? 'arrive' : 'depart'} #{flight}; return #{return_date}"
  end

  def existing_term(max_difference=100)
    terms = self.member.field_terms.sort
    # find earliest field term which ... 
    match_index = terms.find_index do |f| 
      if arrival
        # ... has starting date "near" the travel date
        (f.best_start_date - self.date).abs < max_difference
      else
        # ... starts before travel and is open-ended or has an end_date "near" the travel date.
        f.best_start_date < self.date && 
          (f.best_end_date.nil? || (f.best_end_date - self.date).abs < max_difference)
      end
    end
    match_index ? terms[match_index] : nil       
  end

  # Used for #traveler below, not to parse the member name
  def parse_name(name)
    return nil if name.nil? || name.blank?
    if name =~ /([^ ]+),\s+([^ ]+)\s+([^ ]+)/
      return [ $~[2], $~[3], $~[1] ]
    end
    
    if name =~ /([^ ]+),\s+([^ ]+)/
      return [ $~[2], nil, $~[1] ]
    end
    
    if name =~ /([^ ]+)\s+([^ ]+)\s+([^ ]+)/
      return [ $~[1], $~[2], $~[3] ]
    end
    
    if name =~ /([^ ]+)\s+([^ ]+)/
      return [ $~[1], nil, $~[2] ]
    end

    return [nil, nil, name.strip]
  end      
      
  # Normally, member is an actual person in the database. However, a travel record can
  # be free-floating, not associated with a member. In this case, corresponding to the "else"
  # clause below, we generate a temporary Member object just so that we have the name
  # values available, extracted from the first of the "extra_travelers" names.
  def traveler
    if member_id
      Member.find(member_id)
    else
      # Use the first name in other_travelers (delimited by ';') and 
      # parse it to first, middle, last names.
      # If there is no name, use "?" as a stand-in.
      name = parse_name(self.other_travelers.split(";")[0]) || ['?', nil, nil]
      Member.new(:last_name=>name[2], :first_name=>name[0], :middle_name=>name[1],
                 :name => "#{name[2]}, #{name[0]} #{name[1]}".strip)
    end
  end    

  # For reports, gives names of all specified travelers, both members & non-members
  def travelers
    if member
      names = "#{member.short}"
      spouse_name = member.spouse ? member.spouse.short : "spouse" # Use name if spouse is listed in the database, else "spouse"
      names << " & #{spouse_name}"  if with_spouse
      names << " #{member.last_name}" 
      names << " w kids" if with_children 
      names << ", with #{other_travelers}" unless other_travelers.blank?
      return names
    end
    return other_travelers
  end


  # "Virtual column" for use in listing travels
  def traveler_name
    result = traveler.full_name_short
    if with_spouse
      if member && member.spouse && # There is a spouse listed in the database
           Settings.travel.include_spouse_name_in_list  # the setting is on
        result = "#{member.short} & #{member.spouse.short} #{member.last_name}" 
      else
        result = "M/M " + result 
      end
    end
    result
  end  
  
  # Ensure that record has either a valid member or something in other_travelers
  def name_info
    return true if Member.find_by_id(self.member_id) || (! self.other_travelers.blank?)
    errors[:member] << "Must use existing member or enter name in 'Other travelers'"
    return false
  end
  
  def purpose_category
    case
      when term_passage then 'Term passage'
      when ministry_related then 'Ministry related'
      when personal then 'Personal'
    else                 '?'
    end
  end 
  
  def end_of_term
    self.term_passage && ! arrival
  end
  
  def beginning_of_term
    self.term_passage && arrival
  end
  
end
