class AddSecurityToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :security, :boolean
  end

  def self.down
    remove_column :users, :security
  end
end
