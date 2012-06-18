class RenameMsgStatus < ActiveRecord::Migration
  def self.up
    rename_column :sent_messages, :status, :msg_status
  end

  def self.down
    rename_column :sent_messages, :msg_status, :status
  end
end
