class AddBirthDateToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :birth_date, :date
  end

  def self.down
    remove_column :members, :birth_date
  end
end
