class Status < ActiveRecord::Base
  has_many :members
  has_many :families
  has_many :field_terms
  validates_uniqueness_of :code, :description
  validates_presence_of :code, :description

  def to_label
    "#{description}"
  end

end
