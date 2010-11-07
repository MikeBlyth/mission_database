class AddActiveToMembers < ActiveRecord::Migration
  def self.up
    add_column :statuses, :active, :boolean 
    add_column :statuses, :on_field, :boolean 
  end

  def self.down
    remove_column :statuses, :active
    remove_column :statuses, :on_field
  end
end

