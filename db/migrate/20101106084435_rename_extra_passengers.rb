class RenameExtraPassengers < ActiveRecord::Migration
  def self.up
    rename_column :travels, :extra_passengers, :total_passengers
  end

  def self.down
    rename_column :travels, :total_passengers, :extra_passengers
  end
end
