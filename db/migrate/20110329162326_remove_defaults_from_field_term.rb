class RemoveDefaultsFromFieldTerm < ActiveRecord::Migration
  def self.up
    change_column :field_terms, :primary_work_location_id, :integer, :default=>nil
    change_column :field_terms, :ministry_id, :integer, :default=>nil
    change_column :field_terms, :employment_status_id, :integer, :default=>nil
  end

  def self.down
    change_column :field_terms, :primary_work_location_id, :integer, :default=>UNSPECIFIED
    change_column :field_terms, :ministry_id, :integer, :default=>UNSPECIFIED
    change_column :field_terms, :employment_status_id, :integer, :default=>UNSPECIFIED
  end
end
