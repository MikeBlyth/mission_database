class CreateJqueries < ActiveRecord::Migration
  def self.up
    create_table :jqueries do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :jqueries
  end
end
