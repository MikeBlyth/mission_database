class DropCodesFromPersonnelDetails < ActiveRecord::Migration
  def self.up
        remove_column :personnel_details, :member_id
    remove_column :personnel_details, :ministry_code
    remove_column :personnel_details, :education_code
    remove_column :personnel_details, :location_code
    remove_column :personnel_details, :miss_status
  end

  def self.down
    add_column :personnel_details, :member_id, :integer
    add_column :personnel_details, :ministry_code, :integer
    add_column :personnel_details, :education_code, :integer
    add_column :personnel_details, :location_code, :integer
    add_column :personnel_details, :miss_status, :string
  end
end
