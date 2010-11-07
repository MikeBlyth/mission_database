class CreateTravels < ActiveRecord::Migration
  def self.up
    create_table :travels do |t|
      t.date :date
      t.string :purpose
      t.date :return_date
      t.string :flight
      t.references :member

      t.timestamps
    end
  end

  def self.down
    drop_table :travels
  end
end
