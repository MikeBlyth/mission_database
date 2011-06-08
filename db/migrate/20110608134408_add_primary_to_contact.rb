class AddPrimaryToContact < ActiveRecord::Migration
  def self.up
    add_column :contacts, :is_primary, :boolean
    Contact.update_all({:is_primary=>true}, :contact_type_id => 1)
  end

  def self.down
    remove_column :contacts, :primary
  end
end
