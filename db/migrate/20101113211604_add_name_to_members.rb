class AddNameToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :name, :string
    add_index :members, :name, :unique => true
    add_index :members, :family_id
  end

  def self.down
    remove_column :members, :name
    remove_index :members, :name
    remove_index :members, :family_id
  end
end
