class ChildDefault < ActiveRecord::Migration
  def self.up
    change_column :members, :child, :boolean, :default=>false
  end

  def self.down
  end
end
