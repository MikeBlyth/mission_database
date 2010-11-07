class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms do |t|
      t.references :member
      t.references :status
      t.references :location
      t.references :ministry
      t.date :start_date
      t.date :end_date
      t.date :est_start_date
      t.date :est_end_date
      t.timestamps
    end
  end

  def self.down
    drop_table :terms
  end
end
