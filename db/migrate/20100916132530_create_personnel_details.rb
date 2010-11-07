class CreatePersonnelDetails < ActiveRecord::Migration
  def self.up
    create_table :personnel_details do |t|
      t.integer :member_id
      t.integer :status_code
      t.integer :ministry_code
      t.string :ministry_comment
      t.integer :education_code
      t.string :qualifications
      t.integer :location_code
      t.string :miss_status
      t.date :date_active

      t.timestamps
    end
  end

  def self.down
    drop_table :personnel_details
  end
end
