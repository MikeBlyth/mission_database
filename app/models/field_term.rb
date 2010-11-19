class FieldTerm < ActiveRecord::Base
  belongs_to :member
  belongs_to :location
  belongs_to :status
  belongs_to :ministry

  def to_label
    "#{start_date || est_start_date}"
  end

end
