class AddVariousToPersonnelDetail < ActiveRecord::Migration
  def self.up
    add_column :personnel_details, :ministry_id, :integer
    add_column :personnel_details, :education_id, :integer
    add_column :personnel_details, :location_id, :integer
    add_column :personnel_details, :employment_status_codes_id, :integer
  end

  def self.down
    remove_column :personnel_details, :employment_status_codes_id
    remove_column :personnel_details, :location_id
    remove_column :personnel_details, :education_id
    remove_column :personnel_details, :ministry_id
  end
end
