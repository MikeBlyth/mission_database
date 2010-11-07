class RenameCodeTables < ActiveRecord::Migration
  def self.up
    rename_table :education_codes, :educations
    rename_table :ministry_codes, :ministries
    rename_table :employment_status_codes, :employment_statuses
    rename_table :status_codes, :statuses
  end

  def self.down
    rename_table :education, :education_codes
    rename_table :ministries, :ministry_codes
    rename_table :employment_statuses, :employment_status_codes
    rename_table :statuses, :status_codes
  end
end
