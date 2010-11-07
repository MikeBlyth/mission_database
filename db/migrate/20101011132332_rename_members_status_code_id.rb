class RenameMembersStatusCodeId < ActiveRecord::Migration
  def self.up
    rename_column :members, :status_code_id, :status_id
  end

  def self.down
    rename_column :members, :status_id, :status_code_id 
  end
end
