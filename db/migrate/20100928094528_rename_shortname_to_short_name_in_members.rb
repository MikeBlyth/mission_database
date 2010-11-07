class Renameshort_nameToshort_nameInMembers < ActiveRecord::Migration
  def self.up
    rename_column :members, :short_name, :short_name
  end

  def self.down
    rename_column :members, :short_name, :short_name
  end
end
