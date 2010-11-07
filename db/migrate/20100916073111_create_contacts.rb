class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :person
      t.string :email1
      t.string :email2
      t.string :phone1
      t.string :phone2
      t.string :blog
      t.string :website
      t.string :photosite
      t.string :facebook
      t.string :contact_name
      t.string :address
      t.string :contact_type

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
