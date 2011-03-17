class AddDefaultToWorkLocation < ActiveRecord::Migration
  def self.up
    change_column :members, :work_location_id, :integer, :default=>UNSPECIFIED
  end

  def self.down
  end
end
