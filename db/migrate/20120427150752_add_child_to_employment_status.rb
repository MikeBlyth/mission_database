class AddChildToEmploymentStatus < ActiveRecord::Migration
  def self.up
    add_column :employment_statuses, :child, :boolean
  end

  def self.down
    remove_column :employment_statuses, :child
  end
end
