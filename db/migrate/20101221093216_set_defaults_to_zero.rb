class SetDefaultsToZero < ActiveRecord::Migration
  def self.up
    change_column :families, :location_id, :integer, :default => -1
    change_column :families, :status_id, :integer, :default => -1
    change_column :members, :employment_status_id, :integer, :default => -1
    change_column :members, :education_id, :integer, :default => -1
    change_column :members, :country_id, :integer, :default => -1
    change_column :members, :bloodtype_id, :integer, :default => -1
    change_column :members, :status_id, :integer, :default => -1
    change_column :members, :location_id, :integer, :default => -1
    change_column :members, :ministry_id, :integer, :default => -1
    change_column :field_terms, :status_id, :integer, :default => -1
    change_column :field_terms, :location_id, :integer, :default => -1
    change_column :field_terms, :ministry_id, :integer, :default => -1
    change_column :locations, :city_id, :integer, :default => -1
  end

  def self.down
    change_column :families, :location_id, :integer
    change_column :families, :status_id, :integer
    change_column :members, :employment_status_id, :integer
    change_column :members, :education_id, :integer
    change_column :members, :country_id, :integer
    change_column :members, :bloodtype_id, :integer
    change_column :members, :status_id, :integer
    change_column :members, :location_id, :integer
    change_column :members, :ministry_id, :integer
    change_column :field_terms, :status_id, :integer
    change_column :field_terms, :location_id, :integer
    change_column :field_terms, :ministry_id, :integer
    change_column :locations, :city_id, :integer
  end
end
