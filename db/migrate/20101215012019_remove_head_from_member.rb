class RemoveHeadFromMember < ActiveRecord::Migration
  def self.up
    remove_column :members, :family_head
  end

  def self.down
    add_column :members, :family_head, :boolean  
  end
end
