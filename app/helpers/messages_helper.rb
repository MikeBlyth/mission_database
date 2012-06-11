require 'yaml'
module MessagesHelper

  def to_groups_column(record)
    record.to_groups_array.map {|g| Group.find_by_id(g.to_i).to_s}.join(", ")
  end 
end
