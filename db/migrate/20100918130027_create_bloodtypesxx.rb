class CreateBloodtypes < ActiveRecord::Migration
  def self.up
    create_table :bloodtypes do |t|
      t.string :abo
      t.string :rh
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :bloodtypes
  end
end
