class AddOwnArrangementsToTravel < ActiveRecord::Migration
  def self.up
    add_column :travels, :own_arrangements, :boolean
  end

  def self.down
    remove_column :travels, :own_arrangements
  end
end
