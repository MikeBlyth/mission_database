class AddChildToMember < ActiveRecord::Migration
  def self.up
    add_column :members, :child, :boolean
  end

  def self.down
    remove_column :members, :child
  end
end
