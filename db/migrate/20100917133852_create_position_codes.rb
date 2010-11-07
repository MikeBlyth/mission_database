class CreatePositionCodes < ActiveRecord::Migration
  def self.up
    create_table :position_codes do |t|
      t.string :description
      t.integer :code

      t.timestamps
    end
  end

  def self.down
    drop_table :position_codes
  end
end
