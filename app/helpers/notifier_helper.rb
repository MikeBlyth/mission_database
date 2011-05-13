module NotifierHelper

MISSING = '*** MISSING ***'
  
  def family_summary_content(family)
    s = summary_header + "\n"
    s << "FAMILY HEAD\n"
    s << member_summary_content(family.head)
    s << ("SPOUSE\n" + member_summary_content(family.head.spouse)) if family.married_couple?
    unless family.children.empty?
      s << "CHILDREN\n"
      family.children.each {|c| s << child_summary_content(c) }
    end
    missing = family_missing_info(family)
    unless missing.empty?
      s << "SUMMARY OF IMPORTANT MISSING DATA\n  "
      s << missing.join("\n  ")
    end
    
    return s
  end
  
  def summary_header
    s  = <<"SUMMARYHEADER"
Your SIM Nigeria Database Information

Please take a minute to review the information we have for you on the SIM Nigeria 
database. We're trying to make sure everything is accurate. Contact information is
particularly important since in case of crisis or emergency we need to be able
to contact you. 

If you are not an SIM member then you are receiving this because you're considered
to be under the SIM "umbrella" in some way. If that is incorrect, please let us know.

Confidentiality

Information marked with an asterisk "*" could appear in the SIM Nigeria directory, 
calendars, or other lists. You may request your email, phone numbers, and Skype 
name to be private if you wish. Other contact information may appear in the directory.
The remainder of the information here will not be available except through the SIM 
Nigeria administration.
SUMMARYHEADER
    return s
  end

  def child_summary_content(m)
    "*Name: #{m.first_name}\n*Birth date: #{m.birth_date || MISSING}\nCitizenship: #{m.country.name}\n\n"
  end  
    
  def field_term_content(m)
    f = m.most_recent_term
    p = m.personnel_data
info = <<"FIELDINFO"
Current Term
  Start or projected: #{f.start_date || f.est_start_date || MISSING}      
  End or projected: #{f.end_date || f.est_end_date || MISSING}     
Date Active with SIM: #{p.date_active || MISSING}
Projected end of SIM Nigeria service: #{p.end_nigeria_service || MISSING}
FIELDINFO
    return info
  end  
    
  def member_summary_content(m)
member_info = <<"MEMBERINFO"
*Name: #{m.name}
*Birth date: #{m.birth_date || MISSING } (SIM listing will not include year)
Citizenship: #{m.country.name || MISSING}
*Location in Nigeria: #{m.residence_location}
*Workplace: #{m.work_location}
*Ministry: #{m.ministry}
Ministry comment: #{m.ministry_comment}
*Status: #{m.status}
Education level: #{m.personnel_data.education || MISSING}

*Contact information
#{m.primary_contact ? m.primary_contact.summary_text : '--None on file--'}
Field Service Summary
#{field_term_content(m)}
MEMBERINFO
    return member_info
  end
  
  def member_missing_info(m)
    h = m.health_data
    p = m.personnel_data
    f = m.most_recent_term
    c = m.primary_contact
    if m.child
      required_data = [ [m.birth_date, 'birth date'] ]
    else
      required_data = [ [m.birth_date, "birth date"], [m.country, "country/nationality"],
                        [c.phone_1, "primary phone"], [c.email_1, "primary email"],
                        [p.date_active, "date active with SIM"] ]
      if m.status.on_field && f.end_date.blank?
        required_data << [f.est_end_date, 'estimated end of current term']
      end
      if m.status.code == 'home_assignment' && (f.start_date || f.est_start_date || Date.today) < Date.today  # on furlough but no next-term shown
        required_data << [f.est_start_date, 'estimated start of next term']
      end               
    end
    return required_data.map{|r| r[1] if r[0].blank?}.compact   
  end #method

  def family_missing_info(family)
    s = []
    [family.head, family.spouse, family.children].flatten.each do |m|
      missing = member_missing_info(m)
      s << "#{m.short}: #{missing.join('; ')}" unless missing.empty?
    end
puts "***#{family.head.personnel_data.est_end_of_service}"
    if family.head.personnel_data.est_end_of_service.blank?
      s << "Note: please estimate or guess when you plan to leave SIM Nigeria\nif it is within the next five years"
    end
    return s
  end 

end # module


