# == Schema Information
# Schema version: 20101221093216
#
# Table name: employment_statuses
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  mk_default  :boolean(1)
#

class EmploymentStatus < ActiveRecord::Base
has_many :members, :foreign_key => "employment_status_id"
include ModelHelper

  validates_presence_of :description, :code
    validates_uniqueness_of :code, :description

  def to_label
    "#{description}"
  end


end
