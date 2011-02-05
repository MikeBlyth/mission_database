# == Schema Information
# Schema version: 20101221093216
#
# Table name: educations
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  code        :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class Education < ActiveRecord::Base
include ModelHelper
  validates_presence_of :description, :code
  validates_numericality_of :code, :only_integer => true
  validates_uniqueness_of :code, :description

  def to_label
    "#{description}"
  end

def cwd
  return self.code_with_description
end
end
