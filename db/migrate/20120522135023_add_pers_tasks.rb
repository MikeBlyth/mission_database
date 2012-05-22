class AddPersTasks < ActiveRecord::Migration
  def self.up
    create_table :pers_tasks do |t|
      t.string :task
      t.boolean :pipeline
      t.boolean :orientation
      t.boolean :start_of_term
      t.boolean :end_of_term
      t.boolean :end_of_service
      t.boolean :alert
      t.timestamps
    end
  end

  def self.down
    drop_table :pers_tasks 
  end
end
