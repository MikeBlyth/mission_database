class AddAbbrevToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :abbrev, :string
  end

  def self.down
    remove_column :groups, :abbrev
  end
end
