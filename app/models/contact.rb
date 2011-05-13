# == Schema Information
# Schema version: 20110512072918
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
#  email_private   :boolean
#  phone_private   :boolean
#  skype_private   :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  member_id       :integer         not null
#

class Contact < ActiveRecord::Base
  include ApplicationHelper
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

  # Generate hash of contact info ready for display;
  # * join multiple phones and emails
  # * add "private" notice if needed
  def summary
    phones = smart_join([phone_1, phone_2].map {|p| p.phone_format if p}, ", ")
    return {'Phone' => "#{phones}#{phone_private? ? ' *** private ***' : '' }",
            'Email' => "#{smart_join([email_1, email_2], ', ')}#{email_private? ? ' *** private ***' : '' }",
            'Skype' => "#{skype}#{skype_private? ? ' *** private ***' : '' }",
            'Photos' => "#{photos}",
            'Blog' => "#{blog}",
            'Other website' => "#{other_website}",
            'Facebook' => "#{facebook}",
            }
  end
  
  # Make string form of 'summary', each line beginning with <prefix> 
  # Example if prefix = "\t"
  # "\tPhone: 0803-333-3333\n\tEmail: my@example.com\n\t ..."
  def summary_text(prefix='')
    fields = ['Phone', 'Email', 'Skype', 'Photos', 'Blog', 'Other website', 'Facebook']
    summary_hash = self.summary
    return prefix + (fields.map {|f| "#{f}: #{summary_hash[f]}"}.join("\n"+prefix))
  end
  
  def email_public
    ! email_private
  end  

  def phone_public
    ! email_private
  end  

  def skype_public
    ! email_private
  end  

end
