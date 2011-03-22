# == Schema Information
# Schema version: 20110307141121
#
# Table name: travels
#
#  id               :integer(4)      not null, primary key
#  date             :date
#  purpose          :string(255)
#  return_date      :date
#  flight           :string(255)
#  member_id        :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  origin           :string(255)
#  destination      :string(255)
#  guesthouse       :string(255)
#  baggage          :integer(4)
#  total_passengers :integer(4)
#  confirmed        :date
#  other_travelers  :string(255)
#  with_spouse      :boolean(1)
#  with_children    :boolean(1)
#  arrival          :boolean(1)
#

class Travel < ActiveRecord::Base
 
  belongs_to :member
  validates_presence_of :date
  validate :name_info
  
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
  def member
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
  
  # Ensure that record has either a valid member or something in other_travelers
  def name_info
    return true if Member.find_by_id(self.member_id) || (! self.other_travelers.blank?)
    errors[:member] << "Must use existing member or enter name in 'Other travelers'"
  end
end
