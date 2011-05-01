class AddEndNigeriaServiceToPersonnelData < ActiveRecord::Migration
  def self.up
    add_column :personnel_data, :end_nigeria_service, :date
  end

  def self.down
    remove_column :personnel_data, :end_nigeria_service
  end
end
