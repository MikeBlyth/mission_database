class EmploymentStatus < ActiveRecord::Base
has_many :members, :foreign_key => "employment_status_id"
include ModelHelper

  validates_presence_of :description, :code
    validates_uniqueness_of :code, :description

  def to_label
    "#{description}"
  end


end
