class AddLocCodeToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :code, :integer
  end

  def self.down
    remove_column :locations, :code
  end
end
