module FamiliesHelper

  def members_column(record)
    record.members.collect{|x| x.short}.join(", ")
  end

end
