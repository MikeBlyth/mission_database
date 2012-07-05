module FamiliesHelper

  # This determines what is shown in the "Members" column in the listing of families. It should show husband,
  # wife, and children by order of age.
  def members_column(record)
    if record.husband  # This will be true if there is a married couple
      ordered_members = [record.husband, record.wife]
    else  # Single + perhaps kids
      ordered_members = [record.head]
    end    
    all_members = record.members.order("birth_date ASC")
    all_members.each do |k|
      ordered_members << k unless (ordered_members.include? k) ||
                                  (Settings.family.member_names_dependent_only && !k.dependent)
    end  
    ordered_members.collect{|x| x ? x.short : nil }.join(Settings.family.member_names_delimiter)
  end

  # Returns family data in a formatted hash like
  # :couple => 'Blyth, Mike & Barb', :children=> 'Lisa, Jonathan, Sara', :phone=> '0803-555-5555\n0803-666-6666',
  #   :email => 'mike.blyth@sim.org\nmjblyth@gmail.com'.
  # Private data will be masked unless show_private is true
  # Perhaps would be better to make phone & email arrays?
  def family_data_formatted(f, show_private=false)
    formatted = {}
    head = f.head
    wife = f.wife
    phones = []
    emails = []
    formatted[:couple]= head.last_name_first(:short=>true, :middle=>false) + (wife ? " & #{wife.short}" : '')
    formatted[:children] = smart_join(f.children_names)
    primary_contact_type_code = Settings.contacts.primary_contact_type_code  # which is primary contact?
    # Get the contact record for head, using primary contact type e.g. "on field"
    contact_head = head.primary_contact
    if contact_head   # If there is a valid contact for family head
      phones[0] = contact_head.phone_private ? '---' : format_phone(contact_head.phone_1) || '---'
      emails[0] = contact_head.email_1 || '---'
      if wife # if there IS a wife
        contact_wife = wife.primary_contact
        if contact_wife # if wife has a valid contact record
          phones[1] = format_phone(contact_wife.phone_1) if contact_wife.phone_1 &&
              ! contact_wife.phone_private &&
              contact_wife.phone_1 != contact_head.phone_1
          emails[1] = contact_wife.email_1 if contact_wife.email_1 &&
              contact_wife.email_1 != contact_head.email_1
        end
      end
      # Add a second phone & email if they exist and only one has been used already
      phones[1] = format_phone(contact_head.phone_2) if contact_head.phone_2 && phones.length < 2 
      emails[1] = contact_head.email_2 if contact_head.email_2 && emails.length < 2
    end # if contact_head          
    formatted[:phones] = phones
    formatted[:emails] = emails
    return formatted
  end

  def reported_locations(family)
    head = family.head
    wife = family.wife
    loc = [head.current_location]  # location string; start w first name if married
    loc << wife.current_location if head.is_married? # add wife if there is one
    loc.compact.join('; ')
  end

end
