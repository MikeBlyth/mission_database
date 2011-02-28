class AddWorkSiteToMember < ActiveRecord::Migration
  def self.up
    add_column :members, :work_site_id, :integer
    add_column :members, :temporary_location, :string
    add_column :members, :temporary_location_from_date, :date
    add_column :members, :temporary_location_until_date, :date
    add_index  :members, :status_id
  end

  def self.down
    remove_column :members, :work_site_id
    remove_column :members, :temporary_location
    remove_column :members, :temporary_location_from_date
    remove_column :members, :temporary_location_until_date
    remove_index  :members, :status_id
  end
end
