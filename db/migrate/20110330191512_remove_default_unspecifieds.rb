class RemoveDefaultUnspecifieds < ActiveRecord::Migration
  def self.up
    change_column :members, :work_location_id, :integer, :default=>nil
    change_column :members, :residence_location_id, :integer, :default=>nil
    change_column :members, :country_id, :integer, :default=>nil
    change_column :members, :status_id, :integer, :default=>nil
    change_column :members, :ministry_id, :integer, :default=>nil
    change_column :families, :residence_location_id, :integer, :default=>nil
    change_column :families, :status_id, :integer, :default=>nil
  end

  def self.down
    change_column :members, :work_location_id, :integer, :default=>UNSPECIFIED
    change_column :members, :residence_location_id, :integer, :default=>UNSPECIFIED
    change_column :members, :country_id, :integer, :default=>UNSPECIFIED
    change_column :members, :status_id, :integer, :default=>UNSPECIFIED
    change_column :members, :ministry_id, :integer, :default=>UNSPECIFIED
    change_column :families, :residence_location_id, :integer, :default=>UNSPECIFIED
    change_column :families, :status_id, :integer, :default=>UNSPECIFIED
  end
end
