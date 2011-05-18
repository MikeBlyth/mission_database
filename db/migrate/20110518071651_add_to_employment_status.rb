class AddToEmploymentStatus < ActiveRecord::Migration
  def self.up
    add_column :employment_statuses, :umbrella, :boolean, :default=>false
    add_column :employment_statuses, :org_member, :boolean, :default=>true
    add_column :employment_statuses, :current_use, :boolean, :default=>true
  end

  def self.down
    remove_column :employment_statuses, :umbrella
    remove_column :employment_statuses, :org_member
    remove_column :employment_statuses, :current_use
  end
end
