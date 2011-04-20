class CreateScheduledUpdates < ActiveRecord::Migration
  def self.up
    create_table :scheduled_updates do |t|
      t.date :action_date
      t.integer :member_id
      t.integer :family_id
      t.string :change_type
      t.string :old_value
      t.string :new_value
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_updates
  end
end
