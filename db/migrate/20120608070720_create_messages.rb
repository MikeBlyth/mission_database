class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :body
      t.integer :from_id
      t.string :code
      t.integer :confirm_time_limit
      t.integer :retries
      t.integer :retry_interval
      t.integer :expiration
      t.integer :response_time_limit
      t.integer :importance
      t.string :to_groups

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
