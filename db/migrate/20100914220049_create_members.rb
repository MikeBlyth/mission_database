class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string :family
      t.string :last_name
      t.string :firstname
      t.string :short_name
      t.string :sex
      t.string :nationality
      t.string :ministry

      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
