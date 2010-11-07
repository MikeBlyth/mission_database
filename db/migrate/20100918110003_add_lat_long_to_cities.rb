class AddLatLongToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :latitude, :float
    add_column :cities, :longitude, :float
  end

  def self.down
    remove_column :cities, :longitude
    remove_column :cities, :latitude
  end
end
