require 'yaml'
module MessagesHelper

  def to_groups_column(record)
    puts "**** to_groups=#{record.to_groups}"
    groups = record.to_groups.clone
    if groups.is_a? String
      groups = (YAML.load groups)
    end 
    groups.map {|g| Group.find(g.to_i).to_s}.join(", ")
  end 
end
