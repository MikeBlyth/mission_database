class AddEducationStatusIdToFieldTerms < ActiveRecord::Migration
  def self.up
    add_column :field_terms, :employment_status_id, :integer, :default => 999999
    remove_column :field_terms, :status_id
  end

  def self.down
    remove_column :field_terms, :employment_status_id
    add_column :field_terms, :status_id, :integer, :default => 999999
  end
end
