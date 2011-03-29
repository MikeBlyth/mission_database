class AddEstEndOfServiceToPersonnelData < ActiveRecord::Migration
  def self.up
    add_column :personnel_data, :est_end_of_service, :date
  end

  def self.down
    remove_column :personnel_data, :est_end_of_service
  end
end
