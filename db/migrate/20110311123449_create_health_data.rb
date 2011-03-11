class CreateHealthData < ActiveRecord::Migration
  def self.up
    create_table :health_data do |t|
      t.integer :member_id
      t.integer :bloodtype_id
      t.string :current_meds
      t.string :issues

      t.timestamps
    end
  end

  def self.down
    drop_table :health_data
  end
end
