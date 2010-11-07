class RemoveFirstnameFromMembers < ActiveRecord::Migration
  def self.up
    remove_column :members, :firstname
  end

  def self.down
    add_column :members, :firstname, :string
  end
end
