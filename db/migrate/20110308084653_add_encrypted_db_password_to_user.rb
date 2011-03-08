class AddEncryptedDbPasswordToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :encrypted_db_password, :string
  end

  def self.down
    remove_column :users, :encrypted_db_password
  end
end
