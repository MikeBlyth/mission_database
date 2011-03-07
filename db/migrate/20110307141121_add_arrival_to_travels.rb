class AddArrivalToTravels < ActiveRecord::Migration
  def self.up
    add_column :travels, :arrival, :boolean
  end

  def self.down
    remove_column :travels, :arrival
  end
end
