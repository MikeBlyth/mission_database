class AddFamilyHeadToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :family_head, :boolean
  end

  def self.down
    remove_column :members, :family_head
  end
end
