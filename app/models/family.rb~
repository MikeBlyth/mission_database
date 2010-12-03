class Family < ActiveRecord::Base
  belongs_to :head, :class_name => "Member"
  has_many :members
  belongs_to :status
  belongs_to :location

  def to_label
    if head.nil?
      logger.error "Family with missing head: ID=#{id}, head=#{head_id}"
      return "DB error missing head ID=#{id}, head=#{head_id}"
    end
    "*#{head.last_name_first}"
  end

end
