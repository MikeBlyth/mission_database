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
    return s
  end
  
  def summary_header
    s  = <<"SUMMARYHEADER"
Your SIM Nigeria Database Information

Please take a minute to review the information we have for you on the SIM Nigeria 
database. We're trying to make sure everything is accurate. Contact information is
particularly important since in case of crisis or emergency we need to be able
to contact you. 

If you are not an SIM Member then you are receiving this because you're considered
to be under the SIM "umbrella" in some way. If that is incorrect, the please let
us know.
SUMMARYHEADER
    return s
  end

  def child_summary_content(m)
    "Name: #{m.first_name}\nBirth date: #{m.birth_date || MISSING}\nCitizenship: #{m.country.name}\n\n"
  end  
    

  def member_summary_content(m)
member_info = <<"MEMBERINFO"
Name: #{m.name}
Birth date: #{m.birth_date || MISSING }
Citizenship: #{m.country.name || MISSING}
Location in Nigeria: #{m.residence_location}
Workplace: #{m.work_location}
Ministry: #{m.ministry}
Status: #{m.status}

Contact information
#{m.primary_contact ? m.primary_contact.summary_text : '--None on file--'}
MEMBERINFO
    return member_info
  end
  
end # module


