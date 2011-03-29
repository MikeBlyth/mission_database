class CreateCalendarEvents < ActiveRecord::Migration
  def self.up
    create_table :calendar_events do |t|
      t.datetime :date
      t.string :event

      t.timestamps
    end
  end

  def self.down
    drop_table :calendar_events
  end
end
