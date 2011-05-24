class AddPipelineAndLeaveToStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :pipeline, :boolean
    add_column :statuses, :leave, :boolean
    add_column :statuses, :home_assignment, :boolean
  end

  def self.down
    remove_column :statuses, :leave
    remove_column :statuses, :pipeline
    remove_column :statuses, :home_assignment
  end
end
