class AddEffectedToTravel < ActiveRecord::Migration
  def self.up
    add_column :travels, :effected, :string
  end

  def self.down
    remove_column :travels, :effected
  end
end
