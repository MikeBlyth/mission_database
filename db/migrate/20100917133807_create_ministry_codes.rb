class CreateMinistryCodes < ActiveRecord::Migration
  def self.up
    create_table :ministry_codes do |t|
      t.string :description
      t.integer :code

      t.timestamps
    end
  end

  def self.down
    drop_table :ministry_codes
  end
end
