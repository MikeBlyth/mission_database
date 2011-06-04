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
  before_validation :standardize_phone_numbers

  def to_label
    if contact_type.nil?
      "Error-missing contact_type"
    else
      "#{contact_type.description}"
    end  
  end

  def self.recently_updated(since=Settings.contacts.updates_window)
    return self.where("contacts.updated_at > ?", Date.today - since.days).includes(:member)
  end

  # Generate hash of contact info ready for display;
  # * join multiple phones and emails
  # * add "private" notice if needed
  def summary(params={})
    phones = smart_join([phone_1, phone_2].map {|p| p.phone_format if p}, ", ")
    emails = smart_join([email_1, email_2], ', ')
    override_private = params[:override_private]    
    return {'Phone' => filter_private(phones, phone_private, override_private),
            'Email' => filter_private(emails, email_private, override_private),
            'Skype' => filter_private(skype, skype_private, override_private),
            'Photos' => "#{photos}",
            'Blog' => "#{blog}",
            'Other website' => "#{other_website}",
            'Facebook' => "#{facebook}",
            }
  end
  
  def filter_private(field, marked_as_private, override_private)
    return field unless marked_as_private
    return '*private*' unless override_private
    return "#{field} (private)"
  end 
  
  def standardize_phone_numbers
    self.phone_1 = phone_1.phone_std if phone_1
    self.phone_2 = phone_2.phone_std if phone_2
  end

  # Make string form of 'summary', each line delimited by <separator> and beginning with <prefix> 
  #   (prefix occurs before every line including the first, while separator only BETWEEN lines)
  # Example if prefix = "\t"
  # "\tPhone: 0803-333-3333\n\tEmail: my@example.com\n\t ..."
  def summary_text(prefix='', separator="\n")
    fields = ['Phone', 'Email', 'Skype', 'Photos', 'Blog', 'Other website', 'Facebook']
    summary_hash = self.summary
    return prefix + (fields.map {|f| "#{f}: #{summary_hash[f]}"}.join("#{separator}#{prefix}"))
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
