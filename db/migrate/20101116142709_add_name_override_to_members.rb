class AddNameOverrideToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :name_override, :boolean
  end

  def self.down
    remove_column :members, :name_override
  end
end
