class AddFollowingUpToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :following_up, :integer
  end

  def self.down
    remove_column :messages, :following_up
  end
end
