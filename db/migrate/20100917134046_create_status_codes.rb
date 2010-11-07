class CreateStatusCodes < ActiveRecord::Migration
  def self.up
    create_table :status_codes do |t|
      t.string :description
      t.string :code

      t.timestamps
    end
  end

  def self.down
    drop_table :status_codes
  end
end
