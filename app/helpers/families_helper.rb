module FamiliesHelper

  def members_column(record)
    ordered_members = [record.head, record.head.spouse]
    all_members = record.members.order("birth_date ASC")
    all_members.each do |k|
      ordered_members << k unless ordered_members.include? k
    end  
    ordered_members.collect{|x| x ? x.short : nil }.join(", ")
  end

end
