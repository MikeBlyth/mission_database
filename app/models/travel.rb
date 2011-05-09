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

class Travel < ActiveRecord::Base
 
  belongs_to :member
  validates_presence_of :date
  validate :name_info
  
  def self.current_arrivals
    self.includes(:member).where("arrival AND date <= ? AND ((return_date >= ? OR return_date IS NULL))", Date.today, Date.today)
  end
  
  def self.current_visitors
#    travels = self.current_arrivals.where('(members.status_id NOT IN (?)) OR travels.member_id IS NULL', Status.field_statuses)
    travels = self.current_arrivals.where('(members.status_id NOT IN (?)) OR other_travelers IS NOT NULL', Status.field_statuses)
    visitors = []
    travels.each do |t|
      visitors << {:names => t.travelers,
                   :arrival_date => t.date,
                   :departure_date => t.return_date,
                   }
    end
    return visitors
  end 

  def to_label
    "#{date.to_s} #{flight}"
  end

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
end
