class CreateEducationCodes < ActiveRecord::Migration
  def self.up
    create_table :education_codes do |t|
      t.string :description
      t.integer :code

      t.timestamps
    end
  end

  def self.down
    drop_table :education_codes
  end
end
