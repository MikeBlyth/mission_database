class AddPrimaryToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :primary, :boolean
  end

  def self.down
    remove_column :groups, :primary
  end
end
