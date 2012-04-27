# == Schema Information
# Schema version: 20120427123138
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
  
  # Select travel records of arrivals which are still current (person has not departed)
  # NB *****
  # There is an overall weakness in the way we're using travel records to determine who is present in the
  # country. Travel records are matched (arrival-departure) based on member id or, if none, the other_travelers.
  # This means that the results will be incorrect when the people arriving are not exactly the same as 
  # those departing. Even a husband arriving with his wife, but then departing alone, will probably be
  # interpreted as the wife leaving as well. The whole scheme needs to be rethought if it's going to be 
  # made more accurate.
  # NB 
  # Current_arrivals returns an array of _Travel_ records (linked with members)
  def self.current_arrivals
    # self.includes(:member).where("arrival AND date <= ? AND ((return_date >= ? OR return_date IS NULL))", Date.today, Date.today)
    all_travel = self.includes(:member).where("date <= ?", Date.today).order('member_id, other_travelers, date DESC')  
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
#  def self.current_visitors -- OLD!
#    # travels = self.current_arrivals.where("(members.status_id NOT IN (?)) OR other_travelers > ''", Status.field_statuses)
#    travels = self.current_arrivals.delete_if {|t| t.member && t.member.on_field && t.other_travelers.blank?}
#    visitors = []
#    travels.each do |t|
#      # Add contact info if there is a (database) member as a visitor
#      if t.member && t.member.primary_contact
#        contact = t.member.primary_contact
#        # Include the name only if there are other travelers to be distinguished
#        contacts_name = t.other_travelers ? "#{t.member.full_name_short}: " : ''
#        contacts = contacts_name + smart_join(
#                                         [format_phone(contact.phone_1),
#                                          t.member.primary_contact.email_1 ])
#      else
#        contacts = ''
#      end

#      # If the traveler is a (database) member with on-field status, then don't count her as a visitor
#      if t.member && t.member.on_field
#        visitor_names = t.other_travelers # just the other travelers since primary one has on-field status
#      else
#        visitor_names = t.travelers  # formatted string with primary & other travelers
#      end

#      visitors << {:names => visitor_names,
#                   :arrival_date => t.date,
#                   :departure_date => t.return_date,
#                   :contacts => contacts
#                   }
#    end
#    return visitors
#  end 

  def self.current_visitors
    # travels = self.current_arrivals.where("(members.status_id NOT IN (?)) OR other_travelers > ''", Status.field_statuses)
    visitor_list = self.current_travel_status_hash.delete_if { |traveler, hash| 
        traveler.class == Fixnum && Member.find(traveler).on_field ||  # traveler is a member with on_field status
        ! hash[:arrival]  # status is departed
        }
    visitors = []
    visitor_list.each do |traveler, hash|
      # Add contact info if there is a (database) member as a visitor
      if traveler.class == Fixnum 
        member = Member.find(traveler)
        name = member.full_name_short
        contacts = format_phone(member.primary_contact.phone_1) if member.primary_contact
        ## Include the name only if there are other travelers to be distinguished
        # contacts_name = t.other_travelers ? "#{t.member.full_name_short}: " : ''
        # contacts = smart_join(
        #                       [format_phone(contact.phone_1),
        #                        member.primary_contact.email_1 ])
      else
        contacts = ''
        name = traveler
      end

      visitors << {:names => name,
                   :arrival_date => hash[:date],
                   :departure_date => hash[:return_date],
                   :contacts => contacts
                   }
    end
    return visitors.sort {|a, b| a[:arrival_date] <=> b[:arrival_date]}
  end 

  # Use member field, with_spouse, and other_travelers to generate an array of all travelers 
  #   for this travel record. 
  # NB: Members and spouses are included as their member ids (integers)
  #   while other travelers are listed by name (strings). 
  # The other_travelers field is parsed
  #   twice: first split by ";" for separate sets of people, then by "&" or "and" to split
  #   couples. Examples:
  # * Mike Blyth; Santa Claus ==> ['Mike Blyth', 'Santa Claus']
  # * Mike Blyth; Santa & Mrs. Claus ==> ['Mike Blyth', 'Santa Claus', 'Mrs. Claus']
  # * Mike & Barb Blyth ==> ['Mike Blyth', 'Barb Blyth']
  # * Mike and Barb Blyth ==> ['Mike Blyth', 'Barb Blyth']
  # * Mike Blyth ==> ['Mike Blyth']
  # * Mike & Little Bo Peep ==> ["Mike Peep", "Little Bo Peep"]
  # * Mike Blyth & Little Bo Peep ==> ["Mike Blyth", "Little Bo Peep"]  
  def traveler_array
    # Parse the other_travelers field
  #  return [self.member.id] unless self.other_travelers  # if nil, just return member
    if !self.other_travelers.blank?
      others = self.other_travelers.split(/;|,/).map {|n| n.strip}.compact.map do |n|
        n.sub(/^(\w*) +(&|and|) +(.*) +(.*)/,'\1 \4; \3 \4').gsub(/\s+/,' ').split(/ & | and |; /)
      end.flatten
    else
      others = []
    end  
    # Add the member & spouse if any
    return (
            [(self.member.id if self.member), 
             (self.member.spouse.id if self.member && self.with_spouse)] + 
            others).compact
  end

  # Finds the latest travel record for each person who has traveled. 
  # - Since any travel record can include multiple travelers, in various combinations
  #   and since Travel can't be indexed by them, we have to go through each record from the
  #   beginning. There should be a limit (5 years?) so it won't be necessary to go through
  #   20 years of records to see if someone is still on the field!
  def self.current_travel_status_hash(date=Date.today)
    summary = {}
    self.where('date <= ?', date).order('date').each do |t|
      t.traveler_array.each do | traveler |
        unless summary[traveler] # create new person in hash if not existing
          summary[traveler] ||= {}  
        end
        summary[traveler][:date] = t.date
        summary[traveler][:return_date] = t.return_date
        summary[traveler][:arrival] = t.arrival
        summary[traveler][:travel_rec] = t  # 
      end
    end
    return summary
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
    if name =~ /([^ ]+)\s+(&|and)\s+([^ ]+)\s+([^ ]+)/
      return [ "#{$~[1]} & #{$~[3]}", nil, $~[4] ]
    end
    
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
    return other_travelers if member_id.nil?
    result = traveler.full_name_short
    if with_spouse
      if member && member.spouse && # There is a spouse listed in the database
           Settings.travel.include_spouse_name_in_list  # the setting is on
        result = "#{member.short} & #{member.spouse.short} #{member.last_name}" 
      else
        result = "M/M " + result 
      end
    end
    result << " with #{other_travelers}" unless other_travelers.blank?
    return result
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
