module GroupsHelper

  def members_column(record)
    "Member"
#    if record.husband  # This will be true if there is a married couple
#      ordered_members = [record.husband, record.wife]
#    else  # Single + perhaps kids
#      ordered_members = [record.head]
#    end    
#    all_members = record.members.order("birth_date ASC")
#    all_members.each do |k|
#      ordered_members << k unless (ordered_members.include? k) ||
#                                  (Settings.family.member_names_dependent_only && !k.dependent)
#    end  
#    ordered_members.collect{|x| x ? x.short : nil }.join(Settings.family.member_names_delimiter)
  end


end
