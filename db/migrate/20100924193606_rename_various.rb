class RenameVarious < ActiveRecord::Migration
  def self.up
    rename_column :contacts, :contact_type, :contact_type_id
  end

  def self.down
    rename_column :contacts,  :contact_type_id, :contact_type
  end
end
