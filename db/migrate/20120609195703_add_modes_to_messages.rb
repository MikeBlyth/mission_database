class AddModesToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :send_email, :boolean
    add_column :messages, :send_sms, :boolean
    add_column :messages, :user_id, :integer
  end

  def self.down
    remove_column :messages, :send_sms
    remove_column :messages, :send_email
    remove_column :messages, :user_id
  end
end
