class SetHomePrimary < ActiveRecord::Migration
  def self.up
    Member.joins(:status).where("NOT on_field").each do |m|
      if !m.contacts.empty? && !m.primary_contact
        m.contacts.first.update_attribute(:is_primary,true)
      end
    end
  end

  def self.down
    Contact.where("contact_type_id != 1").update_all(:is_primary=>nil)
  end
end
