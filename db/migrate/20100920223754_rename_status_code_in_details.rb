class RenameStatusCodeInDetails < ActiveRecord::Migration
  def self.up
    rename_column :personnel_details, :status_code, :status_code_id
  end

  def self.down
    rename_column :personnel_details, :status_code_id, :status_code
  end
end
