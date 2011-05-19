class StatusList < Hash

  attr_reader :date

  def initialize
    @date=Date.today
    Member.those_active.each do |m|
      self[m.id] = m  # For now, stuff the whole member object into the hash
    end
  end
  
  def status_count(statuses)
    # Count the member records with status_id in the array of target ids
    self.inject(0) {|sum, (id, member) | statuses.include?(member.status_id) ? sum+1 : sum}
  end
  
  def advance
    @date += 1
    transitions = FieldTerm.where("start_date = ? OR end_date = ? OR est_start_date = ? or est_end_date = ?",  
            @date, @date, @date, @date)
    transitions.each do |t|
      next unless self[t.member_id]  #******************** CHANGE!
      start_date = t.start_date || t.est_start_date
      end_date = t.end_date || t.est_end_date
      if start_date == @date 
        self[t.member_id].status = Status.where("on_field").first
      elsif end_date == @date
        self[t.member_id].status = Status.where("on_field IS ? OR on_field = ?", nil, false).first
      end #if
    end #each transition
  end # advance
end
