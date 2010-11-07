class Renamelast_nameTolast_nameInMembers < ActiveRecord::Migration
  def self.up
    rename_column :members, :lastname, :last_name
  end

  def self.down
    rename_column :members, :last_name, :lastname
  end
end
