# == Schema Information
# Schema version: 20110413013605
#
# Table name: contacts
#
#  id              :integer         not null, primary key
#  contact_type_id :integer
#  contact_name    :string(255)
#  address         :string(255)
#  email_1         :string(40)
#  email_2         :string(40)
#  phone_1         :string(15)
#  phone_2         :string(15)
#  blog            :string(100)
#  other_website   :string(100)
#  skype           :string(20)
#  facebook        :string(60)
#  photos          :string(50)
#  email_public    :boolean
#  phone_public    :boolean
#  skype_public    :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  member_id       :integer         not null
#

class Contact < ActiveRecord::Base
  belongs_to :member
  belongs_to :contact_type
  validates_presence_of :member
  validates :email_1, :allow_blank=>true, :email => true
  validates :email_2, :allow_blank=>true, :email => true

  def to_label
    if contact_type.nil?
      "Error-missing contact_type"
    else
      "#{contact_type.description}"
    end  
  end

end
