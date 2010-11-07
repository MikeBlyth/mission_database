class Addmiddle_nameToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :middle_name, :string
    add_column :members, :family_id, :integer
    remove_column :members, :family
  end

  def self.down
    remove_column :members, :family_id
    remove_column :members, :middle_name
    add_column :members, :family, :string
  end
end
