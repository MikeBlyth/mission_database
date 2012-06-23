class AddSmsOnlyToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :sms_only, :string
  end

  def self.down
    remove_column :messages, :sms_only
  end
end
