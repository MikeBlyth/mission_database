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
