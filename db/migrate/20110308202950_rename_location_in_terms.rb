class RenameLocationInTerms < ActiveRecord::Migration
  def self.up
    rename_column :field_terms, :location_id, :primary_work_location_id
    rename_column :members, :location_id, :residence_location_id
    rename_column :families, :location_id, :residence_location_id
    rename_column :members, :work_site_id, :work_location_id
  end

  def self.down
    rename_column :field_terms, :primary_work_location_id, :location_id
    rename_column :members, :residence_location_id, :location_id
    rename_column :families, :residence_location_id, :location_id
    rename_column :members, :work_location_id, :work_site_id
  end
end
