class AddReportedLocationToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :in_country, :boolean
    add_column :members, :reported_location, :string
    add_column :members, :reported_location_time, :datetime
    add_column :members, :reported_location_expires, :datetime
  end

  def self.down
    remove_column :members, :reported_location_time
    remove_column :members, :reported_location
    remove_column :members, :in_country
    remove_column :members, :reported_location_expires
  end
end
