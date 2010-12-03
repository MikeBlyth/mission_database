class AddMkDefaultToEmploymentStatuses < ActiveRecord::Migration
  def self.up
    add_column :employment_statuses, :mk_default, :boolean
  end

  def self.down
    remove_column :employment_statuses, :mk_default
  end
end
