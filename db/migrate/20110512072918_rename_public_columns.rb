class RenamePublicColumns < ActiveRecord::Migration
  def self.up
    rename_column :contacts, :phone_public, :phone_private
    rename_column :contacts, :email_public, :email_private
    rename_column :contacts, :skype_public, :skype_private
    Contact.update_all("phone_private = False")
    Contact.update_all("email_private = False")
    Contact.update_all("skype_private = False")
  end

  def self.down
    rename_column :contacts, :phone_private, :phone_public
    rename_column :contacts, :email_private, :email_public
    rename_column :contacts, :skype_private, :skype_public
    Contact.update_all("phone_public = True")
    Contact.update_all("email_public = True")
    Contact.update_all("skype_public = True")
  end
end
