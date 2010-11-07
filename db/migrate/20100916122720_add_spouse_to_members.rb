class AddSpouseToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :spouse, :integer
  end

  def self.down
    remove_column :members, :spouse
  end
end
