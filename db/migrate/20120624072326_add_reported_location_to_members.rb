class AddReportedLocationToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :in_country, :boolean
    add_column :members, :reported_location, :string
    add_column :members, :reported_location_date, :date
  end

  def self.down
    remove_column :members, :reported_location_date
    remove_column :members, :reported_location
    remove_column :members, :in_country
  end
end
