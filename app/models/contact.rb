# == Schema Information
# Schema version: 20110608134408
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
#  is_primary      :boolean
#

class Contact < ActiveRecord::Base
  include ApplicationHelper
  extend ExportHelper
  belongs_to :member
  belongs_to :contact_type
  validates_presence_of :member
  validates :email_1, :allow_blank=>true, :email => true
  validates :email_2, :allow_blank=>true, :email => true
  before_validation :standardize_phone_numbers
  after_initialize :check_is_primary
  before_save :clear_other_records_is_primary

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

  # This lets us sort contacts according to the name of the member
  def <=>(other)
    # All contacts should belong to a member, but in case there are orphans, check first for nil
    return 0 if self.member.nil? && other.member.nil?
    return 1 if other.member.nil?
    return -1 if self.member.nil?
    self.member.name <=> other.member.name
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
  # Lines without content are not included unless :include_blanks=>true
  def summary_text(params={})
    prefix = params[:prefix] || ''
    separator = params[:separator] || "\n"
    include_blanks = params[:include_blanks]
    fields = ['Phone', 'Email', 'Skype', 'Photos', 'Blog', 'Other website', 'Facebook']
    summary_hash = self.summary
    summary = fields.map do |f|
      content = summary_hash[f]
      "#{f}: #{content}" if (!content.blank? || include_blanks)
    end
    return prefix + summary.compact.join("#{separator}#{prefix}")
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
  
private

  def check_is_primary
    return unless new_record? && is_primary.nil?
    self.is_primary = true if self.member.nil? || 
          (self.member && self.member.contacts.where(:is_primary=>true).empty?)
  end
  
  def clear_other_records_is_primary
    return unless self.member.reload
    if self.member.contacts.length > 0 && self.is_primary && self.id
      self.member.contacts.update_all("is_primary = false", "id != #{id}")
    end
  end
end
