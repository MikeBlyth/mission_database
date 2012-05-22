class AddTasksToFamily < ActiveRecord::Migration
  def self.up
    add_column :families, :tasks, :string
  end

  def self.down
    remove_column :families, :tasks
  end
end
