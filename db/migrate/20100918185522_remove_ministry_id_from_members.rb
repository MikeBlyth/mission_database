class RemoveMinistryIdFromMembers < ActiveRecord::Migration
  def self.up
    remove_column :members, :ministry_id
  end

  def self.down
    add_column :members, :ministry_id, :string
  end
end
