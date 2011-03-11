class AddRolesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :medical, :boolean
    add_column :users, :personnel, :boolean
    add_column :users, :travel, :boolean
    add_column :users, :member, :boolean
    add_column :users, :immigration, :boolean
    add_column :users, :asst_personnel, :boolean
  end

  def self.down
    remove_column :users, :asst_personnel
    remove_column :users, :immigration
    remove_column :users, :member
    remove_column :users, :travel
    remove_column :users, :personnel
    remove_column :users, :medical
  end
end
